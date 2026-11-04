#!/bin/bash
#
# Idempotent synchronization for the itops-scripts repository (or any git repo).
#
# Safe to run from cron every hour on any number of machines:
#   - concurrent runs on the same machine are serialized with flock;
#   - a second run without changes is a no-op (no empty commits, no pushes);
#   - fast-forward pulls never create merge commits;
#   - diverged histories are rebased when clean, otherwise the script stops
#     with instructions instead of pushing a conflicted merge;
#   - the GitHub token never appears in the process list or in push URLs.
#
# Backward compatible: git-sync.sh [repo-path]
#
set -euo pipefail

PATH="${PREFIX:+$PREFIX/bin:}/usr/local/bin:/usr/bin:/bin:${PATH:-}"
export PATH

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASKPASS="$SCRIPT_DIR/git-askpass-github.sh"

REPO=""
BRANCH=""
READ_ONLY=0
NO_PUSH=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [repo-path] [options]

Options:
  --repo PATH     Repository to synchronize (default: current directory)
  --branch NAME   Branch to synchronize (default: current branch)
  --read-only     Only fetch and fast-forward; never commit or push
  --no-push       Commit and fast-forward, but never push
  -h, --help      Show this help

Exit codes:
  0  synchronized (or already up to date)
  1  configuration/validation error
  2  divergence: manual conflict resolution required
  4  local changes present but pushing is disabled, or push
     credentials are missing
  5  push failed (another machine may have pushed concurrently;
     will retry on the next run)
EOF
}

log() {
    printf '[%s] %s\n' "$(date -Iseconds)" "$*"
}

die() {
    local code="$1"
    shift
    printf 'ERROR: %s\n' "$*" >&2
    exit "$code"
}

# Backward compatibility: an optional positional repo path, plus options.
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --repo)       ARGS+=("$arg") ;;
        --branch)     ARGS+=("$arg") ;;
        --read-only|--no-push|-h|--help) ARGS+=("$arg") ;;
        --*)          die 1 "unknown option: $arg (try --help)" ;;
        *)
            if [ -z "$REPO" ] && [ -d "$arg" ]; then
                REPO="$arg"
            else
                die 1 "unknown argument: $arg (try --help)"
            fi
            ;;
    esac
done
if [ "${#ARGS[@]}" -gt 0 ]; then
    set -- "${ARGS[@]}"
else
    set --
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --repo)       REPO="${2:?missing value for --repo}"; shift 2 ;;
        --branch)     BRANCH="${2:?missing value for --branch}"; shift 2 ;;
        --read-only)  READ_ONLY=1; shift ;;
        --no-push)    NO_PUSH=1; shift ;;
        -h|--help)    usage; exit 0 ;;
        *)            die 1 "unknown option: $1 (try --help)" ;;
    esac
done

[ -n "$REPO" ] || REPO="$PWD"
[ -d "$REPO" ] || die 1 "repository not found: $REPO"
REPO="$(cd -- "$REPO" && pwd)"
cd -- "$REPO"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die 1 "not a git working tree: $REPO"
REPO="$(git rev-parse --show-toplevel)"
cd -- "$REPO"

git remote get-url origin >/dev/null 2>&1 \
    || die 1 "remote 'origin' is not configured in $REPO"

if [ -z "$BRANCH" ]; then
    BRANCH="$(git branch --show-current)" || true
    [ -n "$BRANCH" ] || die 1 "detached HEAD in $REPO; use --branch NAME"
fi

# Serialize concurrent runs (cron may overlap with a previous slow run).
REPO_HASH="$(printf '%s' "$REPO" | md5sum | cut -c1-12)"
LOCK_FILE="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/git-sync-$(id -u)-$REPO_HASH.lock"
exec 9>"$LOCK_FILE" || die 1 "cannot create lock file: $LOCK_FILE"
if ! flock -n 9; then
    log "another git-sync process is running for $REPO; skipping"
    exit 0
fi

REMOTE_URL="$(git remote get-url origin)"
GIT_CRED=()
NEED_PUSH_AUTH=0
case "$REMOTE_URL" in
    https://*|http://*)
        # Pulls from a public repo work without credentials; pushes need them.
        # GIT_ASKPASS is only wired up if a push turns out to be necessary.
        export GIT_TERMINAL_PROMPT=0
        ;;
    ssh://*|git@*|file://*|/*)
        export GIT_TERMINAL_PROMPT=0
        ;;
    *)
        die 1 "unsupported origin URL: $REMOTE_URL"
        ;;
esac

HOST="$(hostname -s 2>/dev/null || hostname)"
log "synchronizing $(basename "$REPO") [$BRANCH] on $HOST"

git fetch --prune origin "$BRANCH" || die 1 "fetch from origin failed"

LOCAL="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse "origin/$BRANCH")"

commit_local_changes() {
    [ "$READ_ONLY" -eq 0 ] || return 0
    # Stage everything Git tracks or would newly track (respects .gitignore),
    # including the repo root (the old per-directory loop missed it).
    git add -A
    if git diff --cached --quiet; then
        return 0
    fi
    if [ -z "$(git config user.name || true)" ] || [ -z "$(git config user.email || true)" ]; then
        die 1 "git user.name/user.email are not set; run utils/git-update-id.sh once interactively"
    fi
    git commit -q -m "Update scripts from $HOST $(date '+%Y-%m-%d %H:%M:%S %z')"
    LOCAL="$(git rev-parse HEAD)"
    log "committed local changes as $LOCAL"
}

wire_push_auth() {
    [ "$NEED_PUSH_AUTH" -eq 1 ] && return 0
    NEED_PUSH_AUTH=1
    case "$REMOTE_URL" in
        https://*|http://*)
            [ -x "$ASKPASS" ] || die 4 "push needed but askpass helper is not executable: $ASKPASS"
            [ -r "$HOME/.github-usr" ] && [ -r "$HOME/.github-pwd" ] \
                || die 4 "push needed but $HOME/.github-usr or $HOME/.github-pwd is missing (run utils/git-update-id.sh once interactively)"
            export GIT_ASKPASS="$ASKPASS"
            GIT_CRED=(-c credential.helper=)
            ;;
    esac
}

do_push() {
    wire_push_auth
    if git "${GIT_CRED[@]}" push origin "HEAD:$BRANCH"; then
        log "pushed to origin/$BRANCH"
        return 0
    fi
    # A concurrent machine may have pushed first; rebase once and retry.
    log "push rejected; fetching and retrying once"
    git fetch --prune origin "$BRANCH" || die 1 "fetch from origin failed"
    REMOTE="$(git rev-parse "origin/$BRANCH")"
    if [ "$(git rev-parse HEAD)" = "$REMOTE" ]; then
        log "up to date"
        return 0
    fi
    if git merge-base --is-ancestor "$REMOTE" HEAD; then
        git "${GIT_CRED[@]}" push origin "HEAD:$BRANCH" \
            || die 5 "push failed; will retry on the next run"
        log "pushed to origin/$BRANCH"
        return 0
    fi
    if ! git rebase "origin/$BRANCH"; then
        git rebase --abort || true
        die 2 "push rejected and rebase conflicts need manual resolution in $REPO"
    fi
    git "${GIT_CRED[@]}" push origin "HEAD:$BRANCH" \
        || die 5 "push failed after rebase; will retry on the next run"
    log "pushed to origin/$BRANCH after rebase"
}

# 1. Commit local work first so a later fast-forward never touches dirty files.
commit_local_changes
LOCAL="$(git rev-parse HEAD)"

# 2. Reconcile with the remote without ever creating merge commits.
if [ "$READ_ONLY" -eq 1 ]; then
    if ! git diff --quiet || ! git diff --cached --quiet; then
        die 4 "local changes present in read-only mode; commit or stash them manually"
    fi
fi

if [ "$LOCAL" = "$REMOTE" ]; then
    log "up to date"
    exit 0
fi

if git merge-base --is-ancestor "$REMOTE" "$LOCAL"; then
    # Local is ahead.
    if [ "$READ_ONLY" -eq 1 ] || [ "$NO_PUSH" -eq 1 ]; then
        die 4 "local branch is ahead of origin/$BRANCH but pushing is disabled"
    fi
    do_push
    exit 0
fi

if git merge-base --is-ancestor "$LOCAL" "$REMOTE"; then
    # Remote is ahead; fast-forward only.
    if ! git merge --ff-only "origin/$BRANCH" >/dev/null; then
        die 2 "fast-forward blocked (dirty tree or would overwrite untracked files) in $REPO"
    fi
    log "fast-forwarded to origin/$BRANCH"
    exit 0
fi

# 3. Diverged: rebase local commits onto the remote when clean.
if [ "$READ_ONLY" -eq 1 ]; then
    die 2 "local and remote histories have diverged; manual resolution required in $REPO"
fi
log "histories diverged; rebasing local commits onto origin/$BRANCH"
if ! git rebase "origin/$BRANCH"; then
    git rebase --abort || true
    cat >&2 <<EOF
ERROR: local and remote histories have diverged with conflicting changes.

No merge commit was created. Resolve manually:

  cd "$REPO"
  git status
  git rebase origin/$BRANCH   # resolve, then: git rebase --continue
  git push origin HEAD:$BRANCH

EOF
    exit 2
fi
LOCAL="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse "origin/$BRANCH")"
if [ "$LOCAL" = "$REMOTE" ]; then
    log "up to date after rebase"
    exit 0
fi
if [ "$NO_PUSH" -eq 1 ]; then
    die 4 "rebased onto origin/$BRANCH but pushing is disabled (--no-push)"
fi
do_push

#!/bin/bash
#
# Conflict-safe synchronization for the private secrets vault repository.
#
# Git cannot merge binary KeePass databases. This script therefore:
#   - pulls only when the local branch can be fast-forwarded;
#   - commits and pushes only the configured vault file;
#   - on divergence, saves both versions and stops for a manual merge.
#
# It never resolves a database conflict automatically.
#
set -euo pipefail

PATH="${PREFIX:+$PREFIX/bin:}/usr/local/bin:/usr/bin:/bin:${PATH:-}"
export PATH

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASKPASS="$SCRIPT_DIR/git-askpass-github.sh"

REPO="${SECRETS_REPO:-$HOME/secrets-vault}"
BRANCH="${SECRETS_BRANCH:-main}"
DB_PATH="${SECRETS_DB_PATH:-vault/hta-itops.kdbx}"
BACKUP_DIR="${SECRETS_BACKUP_DIR:-$HOME/secrets-vault-backups}"
READ_ONLY=0
HOST="$(hostname -s 2>/dev/null || hostname)"
STAMP="$(date +%Y%m%d-%H%M%S)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --repo PATH          Local secrets repository (default: ~/secrets-vault)
  --branch NAME        Branch to synchronize (default: main)
  --db PATH            Vault path inside the repository (default: vault/hta-itops.kdbx)
  --backup-dir PATH    Directory for conflict copies (default: ~/secrets-vault-backups)
  --read-only          Only pull; never commit or push
  -h, --help           Show this help

Exit codes:
  0  synchronized
  1  configuration/validation error
  2  divergence: manual KeePassXC merge required
  3  unexpected local changes outside the vault
  4  read-only mode with local changes
  5  push failed
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

while [ $# -gt 0 ]; do
    case "$1" in
        --repo)       REPO="${2:?missing value for --repo}"; shift 2 ;;
        --branch)     BRANCH="${2:?missing value for --branch}"; shift 2 ;;
        --db)         DB_PATH="${2:?missing value for --db}"; shift 2 ;;
        --backup-dir) BACKUP_DIR="${2:?missing value for --backup-dir}"; shift 2 ;;
        --read-only)  READ_ONLY=1; shift ;;
        -h|--help)    usage; exit 0 ;;
        *)            die 1 "unknown option: $1 (try --help)" ;;
    esac
done

[ -d "$REPO" ] || die 1 "repository not found: $REPO"
REPO="$(cd -- "$REPO" && pwd)"
cd -- "$REPO"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die 1 "not a git working tree: $REPO"

git remote get-url origin >/dev/null 2>&1 \
    || die 1 "remote 'origin' is not configured in $REPO"

git ls-files --error-unmatch -- "$DB_PATH" >/dev/null 2>&1 \
    || die 1 "vault file is not tracked in $REPO: $DB_PATH"

[ -f "$DB_PATH" ] || die 1 "vault file does not exist: $REPO/$DB_PATH"

MAGIC="$(od -An -tx1 -N8 -- "$DB_PATH" | tr -d ' \n')"
[ "$MAGIC" = "03d9a29a67fb4bb5" ] \
    || die 1 "refusing to sync: $DB_PATH does not look like a KDBX database"

# Fresh clones check out 644 (git only tracks the +x bit); the vault must
# stay readable only by its owner.
chmod 600 -- "$DB_PATH" \
    || die 1 "cannot set 600 permissions on $DB_PATH"

LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/secrets-sync-$(id -u).lock"
exec 9>"$LOCK_FILE" || die 1 "cannot create lock file: $LOCK_FILE"
if ! flock -n 9; then
    log "another secrets-sync process is running; skipping"
    exit 0
fi

REMOTE_URL="$(git remote get-url origin)"
GIT_CRED=()
case "$REMOTE_URL" in
    https://*|http://*)
        [ -x "$ASKPASS" ] || die 1 "askpass helper is not executable: $ASKPASS"
        [ -r "$HOME/.github-usr" ] && [ -r "$HOME/.github-pwd" ] \
            || die 1 "missing $HOME/.github-usr or $HOME/.github-pwd (run utils/git-update-id.sh)"
        export GIT_ASKPASS="$ASKPASS"
        export GIT_TERMINAL_PROMPT=0
        # Ignore any global credential helper so the same mechanism works on
        # every machine, including those without gh installed.
        GIT_CRED=(-c credential.helper=)
        ;;
    ssh://*|git@*|file://*|/*)
        export GIT_TERMINAL_PROMPT=0
        ;;
    *)
        die 1 "unsupported origin URL: $REMOTE_URL"
        ;;
esac

git "${GIT_CRED[@]}" fetch --prune origin "$BRANCH"

LOCAL="$(git rev-parse HEAD)"
REMOTE="$(git rev-parse "origin/$BRANCH")"

# Refuse to touch a repository with changes outside the vault. This prevents
# committing unrelated files by accident.
OTHER_CHANGES="$(git status --porcelain --untracked-files=no | grep -vF -- "$DB_PATH" || true)"
if [ -n "$OTHER_CHANGES" ]; then
    printf '%s\n' "$OTHER_CHANGES" >&2
    die 3 "unexpected local changes outside $DB_PATH; resolve them manually"
fi

DB_CHANGED=0
if ! git diff --quiet -- "$DB_PATH" || ! git diff --cached --quiet -- "$DB_PATH"; then
    DB_CHANGED=1
fi

if [ "$DB_CHANGED" -eq 1 ]; then
    if [ "$READ_ONLY" -eq 1 ]; then
        die 4 "local vault changes found in read-only mode"
    fi
    log "committing local vault changes"
    git add -- "$DB_PATH"
    git commit -m "Update secrets vault from $HOST $STAMP" -- "$DB_PATH" >/dev/null
    LOCAL="$(git rev-parse HEAD)"
fi

if [ "$LOCAL" = "$REMOTE" ]; then
    log "up to date"
    exit 0
fi

if git merge-base --is-ancestor "$REMOTE" "$LOCAL"; then
    # Local is ahead; push below.
    :
elif git merge-base --is-ancestor "$LOCAL" "$REMOTE"; then
    log "fast-forwarding to origin/$BRANCH"
    git merge --ff-only "origin/$BRANCH" >/dev/null
    chmod 600 -- "$DB_PATH" || true
    log "up to date"
    exit 0
else
    install -d -m 700 -- "$BACKUP_DIR"
    LOCAL_COPY="$BACKUP_DIR/$HOST-local-$STAMP.kdbx"
    REMOTE_COPY="$BACKUP_DIR/$HOST-remote-$STAMP.kdbx"
    cp --preserve=mode,timestamps -- "$DB_PATH" "$LOCAL_COPY"
    git show "origin/$BRANCH:$DB_PATH" > "$REMOTE_COPY"
    chmod 600 -- "$LOCAL_COPY" "$REMOTE_COPY"

    cat >&2 <<EOF
ERROR: local and remote vault histories have diverged.

No automatic merge was attempted. Both versions were saved:

  local : $LOCAL_COPY
  remote: $REMOTE_COPY

Merge them manually in KeePassXC, then publish the result with:

  cd "$REPO"
  git reset --hard origin/$BRANCH
  cp <merged-file> "$DB_PATH"
  git add "$DB_PATH"
  git commit -m "Merge secrets vault from $HOST"
  git push origin HEAD:$BRANCH

EOF
    exit 2
fi

if [ "$READ_ONLY" -eq 1 ]; then
    log "read-only mode: local is ahead, not pushing"
    exit 4
fi

log "pushing local commit to origin/$BRANCH"
if ! git "${GIT_CRED[@]}" push origin "HEAD:$BRANCH"; then
    die 5 "push failed; another machine may have pushed concurrently (will retry on next run)"
fi

log "synchronized"

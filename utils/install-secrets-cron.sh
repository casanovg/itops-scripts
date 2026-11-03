#!/bin/bash
#
# Install the hourly secrets-vault synchronization job in the current user's
# crontab. Each machine gets a different minute to reduce push races.
#
# VAULT SCOPE: install ONLY on nb-comet, nb-spirit, hta-opportunity and
# hta-enterprise. Other machines must NOT clone the private vault repo.
#
# Run it manually once per machine:
#   ~/itops-scripts/utils/install-secrets-cron.sh --dry-run
#   ~/itops-scripts/utils/install-secrets-cron.sh
#
set -euo pipefail

PATH="/usr/local/bin:/usr/bin:/bin"
export PATH

HOST="$(hostname -s 2>/dev/null || hostname)"
MINUTE=""
DISABLED=0
READ_ONLY=0
DRY_RUN=0
REMOVE=0
COMMENT="# Synchronize the private secrets vault every 1 hour (unique minute per machine)"

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --minute N      Override the default minute for this host
  --read-only     Configure the job with --read-only
  --disabled      Install the line commented out
  --remove        Remove the secrets-vault job
  --dry-run       Show the resulting crontab without applying it
  -h, --help      Show this help

Default minutes (per host):
  hta-businessmate 12   hta-cloud       14   hta-enterprise  16 *
  hta-fileserver   18   hta-mothership  22   hta-opportunity 24 *
  hta-spirit       26   nb-businessmate 28   nb-spirit       32 *
  nb-hibou         34 (disabled)
  nb-comet         36 * nb-meteor       38   wks-03-nbk      40

  * = vault scope (only these four hosts install secrets-sync):
      nb-comet, nb-spirit, hta-opportunity, hta-enterprise.

After running this, the machine's next "crontab -l > cron/<host>.crontab"
job will mirror the change into the repository.
EOF
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --minute)    MINUTE="${2:?missing value for --minute}"; shift 2 ;;
        --read-only) READ_ONLY=1; shift ;;
        --disabled)  DISABLED=1; shift ;;
        --remove)    REMOVE=1; shift ;;
        --dry-run)   DRY_RUN=1; shift ;;
        -h|--help)   usage; exit 0 ;;
        *)           die "unknown option: $1 (try --help)" ;;
    esac
done

if [ -z "$MINUTE" ]; then
    case "$HOST" in
        hta-businessmate) MINUTE=12 ;;
        hta-cloud)        MINUTE=14 ;;
        hta-enterprise)   MINUTE=16 ;;
        hta-fileserver)   MINUTE=18 ;;
        hta-mothership)   MINUTE=22 ;;
        hta-opportunity)  MINUTE=24 ;;
        hta-spirit)       MINUTE=26 ;;
        nb-businessmate)  MINUTE=28 ;;
        nb-spirit)        MINUTE=32 ;;
        nb-hibou)         MINUTE=34; DISABLED=1 ;;
        nb-comet)         MINUTE=36 ;;
        nb-meteor)        MINUTE=38 ;;
        wks-03-nbk)       MINUTE=40 ;;
        *) die "host '$HOST' is not in the default map; use --minute N" ;;
    esac
fi

case "$MINUTE" in
    ''|*[!0-9]*) die "invalid minute: $MINUTE" ;;
esac
[ "$MINUTE" -ge 0 ] && [ "$MINUTE" -le 59 ] \
    || die "minute must be between 0 and 59"

CURRENT="$(crontab -l 2>/dev/null || true)"
FILTERED="$(printf '%s\n' "$CURRENT" \
    | grep -vF 'utils/secrets-sync.sh' \
    | grep -vF "$COMMENT" || true)"

if [ "$REMOVE" -eq 1 ]; then
    NEW="$FILTERED"
else
    ARGS=""
    [ "$READ_ONLY" -eq 1 ] && ARGS=" --read-only"
    JOB_LINE="$(printf '%3d * * * *     ~/itops-scripts/utils/secrets-sync.sh%s' "$MINUTE" "$ARGS")"
    if [ "$DISABLED" -eq 1 ]; then
        NEW="$FILTERED
$COMMENT (disabled)
# $JOB_LINE"
    else
        NEW="$FILTERED
$COMMENT
$JOB_LINE"
    fi
fi

if [ "$DRY_RUN" -eq 1 ]; then
    printf '%s\n' "$NEW"
    exit 0
fi

BACKUP="$HOME/crontab-backup-$(date +%Y%m%d-%H%M%S).txt"
printf '%s\n' "$CURRENT" > "$BACKUP"
chmod 600 "$BACKUP"

printf '%s\n' "$NEW" | crontab -

if [ "$REMOVE" -eq 1 ]; then
    echo "Removed secrets-vault job from crontab (backup: $BACKUP)"
else
    echo "Installed secrets-vault job at minute $MINUTE (backup: $BACKUP)"
fi

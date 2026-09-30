#!/bin/bash

#
# Update Calibre
# ..............
# 2024-06-05 gustavo.casanova@gmail.com
#

set -o errexit
set -o nounset
set -o pipefail

# Calibre's installer downloads a ~200 MB tarball and caches it under $TMPDIR.
# On this VM /tmp is a 1.9 GB tmpfs, so use the disk backed /var/tmp instead to
# avoid running out of memory while the library server is stopped.
export TMPDIR=/var/tmp

SERVICE="calibre-server.service"
SERVICE_PORT="8099"
INSTALLER_URL="https://download.calibre-ebook.com/linux-installer.sh"
# Created by root on purpose: the installer is downloaded as root too, and wget
# refuses (EACCES) to write into a file owned by the unprivileged user.
INSTALLER_SCRIPT="$(sudo mktemp /var/tmp/calibre-installer.XXXXXX)"
SERVICE_WAS_ACTIVE=0

# Nothing this installer prints is an error on its own: "Failed to find directory
# to install bash completions, using default." is a normal fallback to
# /usr/share/bash-completion/completions/. Only the exit status is trusted.
echo "Calibre updates report 3 harmless informational messages, ignore them:"
echo "  - Failed to find directory to install bash completions, using default."
echo "  - Using previously downloaded calibre-<version>-<arch>.txz"
echo "  - Creating un-installer: /usr/bin/calibre-uninstall"
echo ""

# Always give the library server back the state we found it in, even if this
# script dies half way through (network hang, Ctrl+C, out of memory...).
cleanup() {
    sudo rm -f "$INSTALLER_SCRIPT" || true
    if [ "$SERVICE_WAS_ACTIVE" -eq 1 ] && ! sudo systemctl is-active --quiet "$SERVICE"; then
        echo ""
        echo "Calibre service was left down, starting it back ..."
        sudo systemctl start "$SERVICE" || true
    fi
}
trap cleanup EXIT

# Report the installed version, without failing if calibre is not runnable.
calibre_version() {
    /opt/calibre/calibre --version 2>/dev/null |
        grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || true
}

fail() {
    echo ""
    echo "ERROR: $1"
    exit 1
}

# True when the unit is running *and* really answering on the library port.
# 'systemctl start' on a Type=simple unit returns success even when the process
# dies right afterwards, so is-active alone is not enough.
service_is_serving() {
    systemctl is-active --quiet "$SERVICE" || return 1
    (exec 3<>"/dev/tcp/127.0.0.1/$SERVICE_PORT") 2>/dev/null || return 1
    return 0
}

#
# Pre-flight checks, done while the library server is still running.
#

echo "Checking calibre installation ..."
[ -x /opt/calibre/calibre ] || fail "/opt/calibre/calibre is missing."
sudo systemctl cat "$SERVICE" >/dev/null 2>&1 || fail "$SERVICE unit not found."
command -v python3 >/dev/null 2>&1 || fail "python3 is required by the calibre installer."
command -v wget >/dev/null 2>&1 || fail "wget is required to download the calibre installer."
OLD_VERSION="$(calibre_version)"
echo "  Current version: ${OLD_VERSION:-unknown}"

if sudo systemctl is-active --quiet "$SERVICE"; then
    SERVICE_WAS_ACTIVE=1
fi

# The installer needs room in $TMPDIR for the tarball plus its extraction.
AVAILABLE_KB="$(df -Pk "$TMPDIR" | awk 'NR==2 {print $4}')"
if [ "$AVAILABLE_KB" -lt 1048576 ]; then
    fail "less than 1 GB available in $TMPDIR, not enough for the calibre tarball."
fi
echo "  Free space in $TMPDIR: $((AVAILABLE_KB / 1024)) MB"

# Download the installer up front, while the server is still up. Piping wget
# straight into sh made a failed download look like a successful update: wget
# wrote nothing, sh read an empty script and both returned 0.
echo "Downloading calibre installer ..."
sudo wget --quiet --output-document="$INSTALLER_SCRIPT" "$INSTALLER_URL" ||
    fail "could not download $INSTALLER_URL"
[ -s "$INSTALLER_SCRIPT" ] || fail "the downloaded installer is empty."
sudo chmod 644 "$INSTALLER_SCRIPT"
grep -q 'linux-installer.sh' "$INSTALLER_SCRIPT" ||
    fail "the downloaded file is not the calibre installer."

#
# Update.
#

echo ""
echo "Stopping calibre service..."
sudo systemctl stop "$SERVICE"

echo ""
echo "Updating calibre software..."
# TMPDIR must be passed explicitly, sudo's env_reset strips it from the
# environment and the installer would fall back to /tmp (the 1.9 GB tmpfs).
sudo TMPDIR="$TMPDIR" sh "$INSTALLER_SCRIPT"

echo ""
echo "Starting calibre service..."
sudo systemctl start "$SERVICE"

# 'systemctl start' on a Type=simple unit succeeds even when the process dies
# right afterwards, so confirm the server is really listening again.
echo ""
echo "Verifying calibre service..."
for _ in $(seq 1 15); do
    service_is_serving && break
    sleep 2
done

service_is_serving ||
    fail "$SERVICE is not serving on port $SERVICE_PORT, check: journalctl -u $SERVICE"

NEW_VERSION="$(calibre_version)"
[ -n "$NEW_VERSION" ] || fail "calibre is not runnable after the update."

echo "  New version: $NEW_VERSION"
if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
    echo "  Already up to date, nothing changed."
fi

echo ""
echo "Calibre update finished."
echo ""
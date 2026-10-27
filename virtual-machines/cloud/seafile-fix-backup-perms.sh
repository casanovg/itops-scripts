#!/bin/bash
# Make Seafile storage files readable by netbackup for Backintime backups.
# Seafile Docker runs as root and creates files mode 0600 root:root,
# which Backintime (netbackup) cannot read via sshfs.
set -eu
BASE=/data/seafile-docker-data/seafile/seafile-data/storage
if [ ! -d "$BASE" ]; then
    echo "storage dir not found: $BASE" >&2
    exit 1
fi
# Change group to wheel (netbackup is in wheel) for files not already in wheel
find "$BASE" -type f ! -group wheel -exec chgrp wheel {} +
# Grant group read to files lacking it
find "$BASE" -type f ! -perm -g+r -exec chmod g+r {} +

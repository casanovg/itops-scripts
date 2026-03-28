#!/bin/bash

# Clean logs to free disk space
# ......................................
# 2022-06-22 gustavo.casanova@gmail.com
# Updated: 2026-03-28

if [ "$EUID" -ne 0 ]
	then
		echo ""
		echo "........................................"
		echo ". Please run this script as superuser! ."
		echo ". e.g. \"sudo ./free-space.sh\"          ."
		echo "........................................"
		echo ""
  	exit 1
fi

AUTO_REBOOT=0

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -h, --help    Show this help message and exit"
            echo "  -y, --yes     Automatically reboot the machine without prompting"
            exit 0
            ;;
        -y|--yes)
            AUTO_REBOOT=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage."
            exit 1
            ;;
    esac
done

echo "Cleaning log files to free space..."
echo

# 1. Clean systemd journal cleanly instead of deleting the files
echo "Vacuuming journald..."
journalctl --vacuum-time=1d
# Alternatively, to keep a specific size: journalctl --vacuum-size=100M

# 1.2 Podman / Docker containers log vacuum (rootless or system-wide)
echo "Truncating container logs (Podman/Docker)..."
if command -v podman &> /dev/null; then
    # Podman logs are usually handled by journald (which we just vacuumed)
    # This will only delete dangling images/networks (no running or stopped regular containers)
    podman system prune -f
fi
if command -v docker &> /dev/null; then
    # This will only delete dangling images/networks (no running or stopped regular containers)
    docker system prune -f
    # Truncate JSON log files from Docker
    find /var/lib/docker/containers/ -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null
fi

# 2. General application and system logs
# We use 'truncate' to empty the files without deleting them, 
# preventing file permission and handler issues.
LOG_DIRS=(
    "/var/log/sssd"
    "/var/log/nginx"
    "/var/log/apache2"
    "/var/log/httpd"
    "/var/log/mysql"
    "/var/log/mariadb"
    "/var/log/zoneminder"
    "/var/log/audit"
    "/var/log/jellyfin"
    "/var/log/samba"
    "/var/lib/pgsql/data/log"
    "/data/mattermost/logs"
    "/opt/seafile/logs"
)

for DIR in "${LOG_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Cleaning directory: $DIR"
        find "$DIR" -type f -name "*.log" -exec truncate -s 0 {} \;
        # Truncate zoneminder specifically if it lacks .log extension on some files
        find "$DIR" -type f -name "zm*.log" -exec truncate -s 0 {} \;
        find "$DIR" -type f -name "*.gz" -delete
    fi
done

# 3. Standard system logs
echo "Cleaning standard system logs..."
SYSTEM_LOGS=(
    "/var/log/messages"
    "/var/log/syslog"
    "/var/log/auth.log"
    "/var/log/secure"
    "/var/log/kern.log"
    "/var/log/dmesg"
    "/var/log/cron"
    "/var/log/maillog"
    "/var/log/fail2ban.log"
    "/var/log/audit/audit.log"
)

for LOG in "${SYSTEM_LOGS[@]}"; do
    if [ -f "$LOG" ]; then
        echo "Truncating: $LOG"
        truncate -s 0 "$LOG"
    fi
done

# 4. Clean old rotated log files in /var/log
echo "Removing old rotated logs..."
find /var/log -type f -regex ".*\.[0-9]$" -delete
find /var/log -type f -name "*.gz" -delete
find /var/log -type f -name "*-20[0-9][0-9][0-1][0-9][0-3][0-9]*" -delete

# 5. Clean VirtualBox VM log archives and BackInTime diagnostics (if any)
echo "Removing VirtualBox old logs and specific software residues..."
find / -maxdepth 4 -type f -name "VBox.log.*" -delete 2>/dev/null
find / -maxdepth 4 -type f -ipath "*backintime*.log*" -delete 2>/dev/null

# 6. Clean apt/yum/dnf cache (optional, un-comment if needed)
# echo "Cleaning package manager caches..."
# apt-get clean || yum clean all || dnf clean all

echo ""
echo "File cleanup finished."
echo

# Ask for confirmation before rebooting
if [ "$AUTO_REBOOT" -eq 1 ]; then
    echo "Auto-reboot flag provided (--yes). Proceeding with reboot..."
    REPLY="y"
else
    read -p "Do you want to reboot the machine now? (y/n) " -n 1 -r
    echo
fi

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Rebooting the machine in 9 seconds..."
    SECS=9
    while [ "$SECS" -gt 0 ]; do
        echo -n -e "\r >>>  $SECS     "
        SECS=$((SECS-1))
        sleep 1
    done
    echo -n -e "\r >>>  BYE!  "
    sleep 2
    echo
    echo
    shutdown -r now
fi


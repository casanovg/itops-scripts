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

echo "Cleaning log files to free space..."
echo

# 1. Clean systemd journal cleanly instead of deleting the files
echo "Vacuuming journald..."
journalctl --vacuum-time=1d
# Alternatively, to keep a specific size: journalctl --vacuum-size=100M

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

# 5. Clean apt/yum/dnf cache (optional, un-comment if needed)
# echo "Cleaning package manager caches..."
# apt-get clean || yum clean all || dnf clean all

echo ""
echo "File cleanup finished."
echo

# Ask for confirmation before rebooting
read -p "Do you want to reboot the machine now? (y/n) " -n 1 -r
echo
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



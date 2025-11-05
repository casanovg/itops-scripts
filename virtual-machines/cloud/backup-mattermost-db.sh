#!/bin/sh

# Backup Mattermost PostgreSQL database
# .............................................................
# 2020-03-16 gustavo.casanova@gmail.com (MariaDB version)
# 2025-11-05 Updated for PostgreSQL

# Configuration
BACKUP_DATABASE="/data/mattermost-data/backup-database"
DB_USER="postgres"
DB_NAME="mattermost"
BKP_USR="netbackup"
BKP_GRP="wheel"

# Stop Mattermost service
echo ""
echo "Stopping Mattermost service ..."
sudo systemctl stop mattermost.service

DB_SERVICE_STATUS="$(systemctl is-active postgresql)"

# Backup Mattermost PostgreSQL database
if [ "$DB_SERVICE_STATUS" = "active" ]; then

    # Checking backup destination directory
    if [ ! -d "$BACKUP_DATABASE" ]; then
        echo ""
        echo "Directory $BACKUP_DATABASE DOES NOT exist, creating it ..."
        mkdir -p $BACKUP_DATABASE
    fi

    echo ""
    echo "Backing up Mattermost PostgreSQL database ..."

    # Delete previous mattermost backup
    rm -rf $BACKUP_DATABASE/mattermost*
    
    # Backup updated mattermost database
    echo "Backing mattermost up ..."
    sudo -u $DB_USER pg_dump $DB_NAME > $BACKUP_DATABASE/mattermost.sql."$(date +"%Y-%m-%d_%H-%M-%S")"
    
    # Set correct permissions
    sudo chown -R $BKP_USR:$BKP_GRP $BACKUP_DATABASE
    
else
    echo ""
    echo "WARNING! PostgreSQL not running, unable to back the Mattermost database up!"
fi

# Start Mattermost service
echo ""
echo "Starting Mattermost service ..."
sudo systemctl start mattermost.service
echo ""

# Note: BackInTime backups /data/mattermost (application & config) and 
#       /data/mattermost-data (operational data & database backup)

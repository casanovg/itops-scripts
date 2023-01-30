#!/bin/sh

# Backup Mattermost MySQL (MariaDB) databases and system files
# .............................................................
# 2020-03-16 gustavo.casanova@gmail.com

SYSTEM_DIR="/opt/mattermost"
#SYSTEM_USR="/opt/seafile.my.cnf"
BACKUP_SYSTEM="/data/mattermost-data/backup-system"
BACKUP_DATABASE="/data/mattermost-data/backup-database"
BKP_USR="netbackup"
BKP_GRP="wheel"

# Stop Mattermost services
echo ""
echo "Stopping Mattermost service ..."
sudo systemctl stop mattermost.service

DB_SERVICE_STATUS="$(systemctl is-active mariadb)"

# Backup Mattermost database
if [ "$DB_SERVICE_STATUS" = "active" ]; then

    # Checking backup destination directory
    if [ ! -d "$BACKUP_DATABASE" ]; then
        echo ""
        echo "Directory $BACKUP_DATABASE DOES NOT exists, creating it ..." 
        mkdir -p $BACKUP_DATABASE
    fi

    echo ""
    echo "Backing Mattermost database up ..."

    # Delete previous mattermost
    rm -rf $BACKUP_DATABASE/mattermost*
    # Backup updated mattermost
    echo "Backing mattermost up ..."
    mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt mattermost > $BACKUP_DATABASE/mattermost.sql."$(date +"%Y-%m-%d_%H-%M-%S")"

else
    echo ""
    echo "WARNING! MariaDB not running, unable to back the Mattermost database up!"

fi

# Backup Mattermost system files
echo ""
echo "Backing Mattermost system files up ..."
sudo rsync -r -a $SYSTEM_DIR $BACKUP_SYSTEM
sudo rsync -r -a $SYSTEM_USR $BACKUP_SYSTEM
sudo chown -R $BKP_USR:$BKP_GRP $BACKUP_SYSTEM

# Start Mattermost services
echo ""
echo "Starting Matttermost services ..."
sudo systemctl start mattermost.service
echo ""

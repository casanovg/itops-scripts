#!/bin/sh

# Backup Seafile MySQL (MariaDB) databases and system files
# ..........................................................
# 2020-02-15 gustavo.casanova@gmail.com

SYSTEM_DIR="/opt/seafile"
SYSTEM_USR="/opt/seafile.my.cnf"
BACKUP_SYSTEM="/data/seafile-data/backup-system"
BACKUP_DATABASE="/data/seafile-data/backup-database"
BKP_USR="netbackup"
BKP_GRP="wheel"

# Stop Seafile services
echo ""
echo "Stopping Seafile services ..."
#sudo systemctl stop nginx seahub seafile
~/itops-scripts/virtual-machines/cloud/cl-stop.sh

DB_SERVICE_STATUS="$(systemctl is-active mariadb)"

# Backup Seafile databases
if [ "$DB_SERVICE_STATUS" = "active" ]; then

    # Checking backup destination directory
    if [ ! -d "$BACKUP_DATABASE" ]; then
        echo ""
        echo "Directory $BACKUP_DATABASE DOES NOT exists, creating it ..." 
        mkdir -p $BACKUP_DATABASE
    fi

    echo ""
    echo "Backing Seafile databases up ..."

    # Delete previous ccnet_db
    rm -rf $BACKUP_DATABASE/ccnet_db*
    # Backup updated ccnet_db
    echo "Backing ccnet_db up ..."
    mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt ccnet_db > $BACKUP_DATABASE/ccnet_db.sql."$(date +"%Y-%m-%d_%H-%M-%S")"

    # Delete previous seafile_db
    rm -rf $BACKUP_DATABASE/seafile_db*
    # Backup updated seafile_db
    echo "Backing seafile_db up ..."
    mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt seafile_db > $BACKUP_DATABASE/seafile_db.sql."$(date +"%Y-%m-%d_%H-%M-%S")"

    # Delete previous seahub_db
    rm -rf $BACKUP_DATABASE/seahub_db*
    # Backup updated seahub_db
    echo "Backing seahub_db up ..."
    mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt seahub_db > $BACKUP_DATABASE/seahub_db.sql."$(date +"%Y-%m-%d_%H-%M-%S")"

else
    echo ""
    echo "WARNING! MariaDB not running, unable to back the Seafile databases up!"

fi

# Backup Seafile system files
echo ""
echo "Backing Seafile system files up ..."
sudo rsync -r -a $SYSTEM_DIR $BACKUP_SYSTEM
sudo rsync -r -a $SYSTEM_USR $BACKUP_SYSTEM
sudo chown -R $BKP_USR:$BKP_GRP $BACKUP_SYSTEM

# Start Seafile services
echo ""
echo "Starting Seafile services ..."
#sudo systemctl start seafile seahub nginx
~/itops-scripts/virtual-machines/cloud/cl-start.sh
echo ""

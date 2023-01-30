#!/bin/sh

# Restore Seafile MySQL (MariaDB) databases and system files
# ...........................................................
# 2020-02-15 gustavo.casanova@gmail.com

SYSTEM_DIR="/opt/seafile"
SYSTEM_USR="/opt/seafile.my.cnf"
BACKUP_SYSTEM="/data/seafile-data/backup-system"
BACKUP_DATABASE="/data/seafile-data/backup-database"
BKP_USR="netbackup"
BKP_GRP="wheel"

clear
echo ""
echo " **********************************************"
echo " *     WARNING!     WARNING!     WARNING!     *"
echo " * .......................................... *"
echo " *   If you continue the Seafile file sync    *"
echo " *   service could be severely damaged and    *"
echo " *   become useless. If you are not a system  *"
echo " *   administrator or you do not know what    *"
echo " *   this database restore implies, please    *"
echo " *   exit now!                                *"
echo " **********************************************"
echo ""
echo -en "Please enter \e[38;2;255;0;0mrestore\e[0m to continue, or any key to \e[38;2;0;255;0mexit\e[0m: "
read USER_INPUT

if [ "$USER_INPUT" = "restore" ] || [ "$USER_INPUT" = "Restore" ] || [ "$USER_INPUT" = "RESTORE" ]; then
    echo ""
    echo "Ok, Seafile databases restore starting ..."
else
    echo ""
    echo "Exiting ..."
    echo ""
    exit
fi

# Stop Seafile services
echo ""
echo "Stopping Seafile services ..."
#sudo systemctl stop nginx seahub seafile
~/itops-scripts/virtual-machines/cloud/cl-stop.sh

DB_SERVICE_STATUS="$(systemctl is-active mariadb)"

# Restore Seafile databases
if [ "$DB_SERVICE_STATUS" = "active" ]; then

    echo ""
    echo "Seafile database restore ..."

    # Restore updated ccnet_db
    echo "Restoring ccnet_db ..."
    mysql -h localhost -u root -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" ccnet_db < "$(ls $BACKUP_DATABASE/ccnet_db.sql.*)"

    # Restore updated seafile_db
    echo "Restoring seafile_db ..."
    mysql -h localhost -u root -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" seafile_db < "$(ls $BACKUP_DATABASE/seafile_db.sql.*)"

    # Restore updated seahub_db
    echo "Restoring seahub_db ..."
    mysql -h localhost -u root -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" seahub_db < "$(ls $BACKUP_DATABASE/seahub_db.sql.*)"

else
    echo ""
    echo "WARNING! MariaDB not running, unable to restore the Seafile databases!"

fi

# Restore Seafile system files
echo ""
echo -en "Restore also Seafile system files? (Y/N): "
read USER_INPUT
if [ "$USER_INPUT" = "Y" ] || [ "$USER_INPUT" = "y" ] || [ "$USER_INPUT" = "yes" ] || [ "$USER_INPUT" = "Yes" ] || [ "$USER_INPUT" = "YES" ]
then
    echo ""
    echo "Restoring Seafile system files ..."
    sudo rsync -r -a $BACKUP_SYSTEM/* /opt/.
    sudo chown -R root:wheel /opt/seafile.my.cnf
fi

# Start Seafile services
echo ""
echo "Starting Seafile services ..."
#sudo systemctl start seafile seahub nginx
~/itops-scripts/virtual-machines/cloud/cl-start.sh
echo ""

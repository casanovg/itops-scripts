#!/bin/sh

# Restore Mattermost MySQL (MariaDB) databases and system files
# ..............................................................
# 2020-06-13 gustavo.casanova@gmail.com

SYSTEM_DIR="/opt/mattermost"
BACKUP_SYSTEM="/data/mattermost-data/backup-system"
BACKUP_DATABASE="/data/mattermost-data/backup-database"
BKP_USR="netbackup"
BKP_GRP="wheel"

clear
echo ""
echo " **********************************************"
echo " *     WARNING!     WARNING!     WARNING!     *"
echo " * .......................................... *"
echo " *   If you continue the HTA Mattermost team  *"
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
    echo "Ok, Mattermost database restore starting ..."
else
    echo ""
    echo "Exiting ..."
    echo ""
    exit
fi

# Stop Mattermost services
echo ""
echo "Stopping Mattermost services ..."
sudo systemctl stop nginx.service
sudo systemctl stop mattermost.service

DB_SERVICE_STATUS="$(systemctl is-active mariadb)"

# Restore Mattermost database
if [ "$DB_SERVICE_STATUS" = "active" ]; then

    echo ""
    echo "Mattermost database restore ..."

    # Restore updated mattermost
    echo "Restoring mattermost ..."
    mysql -h localhost -u root -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" mattermost < "$(ls $BACKUP_DATABASE/mattermost.sql.*)"

else
    echo ""
    echo "WARNING! MariaDB not running, unable to restore the Mattermost database!"

fi

## Restore Mattermost system files
#echo ""
#echo -en "Restore also Mattermost system files? (Y/N): "
#read USER_INPUT
#if [ "$USER_INPUT" = "Y" ] || [ "$USER_INPUT" = "y" ] || [ "$USER_INPUT" = "yes" ] || [ "$USER_INPUT" = "Yes" ] || [ "$USER_INPUT" = "YES" ]
#then
#    echo ""
#    echo "Restoring Mattermost system files ..."
#    sudo rsync -r -a $BACKUP_SYSTEM/* /opt/.
#    #--- NO ---sudo chown -R root:wheel /opt/seafile.my.cnf
#fi

# Start Mattermost services
echo ""
echo "Starting Mattermost services ..."
sudo systemctl start mattermost.service
sudo systemctl start nginx.service
echo ""

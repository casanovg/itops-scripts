#!/bin/sh

#
# Backup Seafile MySQL (MariaDB) databases
# ...............................................................
# 2020-02-02 gcasanova@hellermanntyton.com.ar
#

# Stop Seafile services
echo ""
echo "Stopping Seafile services ..."
#sudo systemctl stop nginx seahub seafile
~/itops-scripts/virtual-machines/cloud/cl-stop.sh

SERVICE_STATUS="$(systemctl is-active mariadb)"

if [ "$SERVICE_STATUS" = "active" ]; then

    # Delete previous ccnet_db
    rm -rf /data/seafile-data/database-backup/ccnet_db*
    # Backup updated ccnet_db
    echo ""
    echo "Backing ccnet_db up ..."
    mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt ccnet_db > /data/seafile-data/database-backup/ccnet_db.sql.$(date +"%Y-%m-%d_%H-%M-%S")

    # Delete previous seafile_db
    rm -rf /data/seafile-data/database-backup/seafile_db*
    # Backup updated seafile_db
    echo ""
    echo "Backing seafile_db up ..."
    mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt seafile_db > /data/seafile-data/database-backup/seafile_db.sql.$(date +"%Y-%m-%d_%H-%M-%S")

    # Delete previous seahub_db
    rm -rf /data/seafile-data/database-backup/seahub_db*
    # Backup updated seahub_db
    echo ""
    echo "Backing seahub_db up ..."
    mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt seahub_db > /data/seafile-data/database-backup/seahub_db.sql.$(date +"%Y-%m-%d_%H-%M-%S")

else
    echo ""
    echo "WARNING! MariaDB not running, unable to back the Seafile databases up!"

fi

# Start Seafile services
echo ""
echo "Starting Seafile services ..."
#sudo systemctl start seafile seahub nginx
~/itops-scripts/virtual-machines/cloud/cl-start.sh
echo ""

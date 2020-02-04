#!/bin/sh

#
# Backup Seafile MySQL databases
# ...............................................................
# 2020-02-02 gcasanova@hellermanntyton.com.ar
#

# Stop Seafile services
sudo systemctl stop nginx seahub seafile

# Delete previous ccnet_db
rm -rf /data/seafile-data/database-backup/ccnet_db*
# Backup updated ccnet_db
mysqldump -h localhost -uroot -p"$(~/itops-scripts/virtual-machines/cloud/vm-setup/get-mysql-root-pwd.sh)" --opt ccnet_db > /data/seafile-data/database-backup/ccnet_db.sql.$(date +"%Y-%m-%d-%H-%M-%S")

# Start Seafile services
sudo systemctl start seafile seahub nginx

#!/bin/bash

#
# Seafile storage mainteinance
# ............................................
# 2021-02-05 gcasanova@hellermanntyton.com.ar
#

#####
# Uncomment the following line if you rather want to run the script manually.
# Display usage if the script is not run as root user
#        if [[ $USER != "root" ]]; then
#                echo "This script must be run as root user!"
#                exit 1
#        fi
#
# echo "Super User detected!!"
# read -p "Press [ENTER] to start the procedure, this will stop the seafile server!!"
#####

SEAFILE_PATH="/opt/seafile"
SERVICE_USER="netbackup"

# Stop the server
echo Stopping the Seafile server ...
sudo systemctl stop seafile.service
sudo systemctl stop seahub.service
echo

echo Giving the server some time to shut down properly ...
sleep 20
echo

# Check and repair libraries
echo Seafile FSCK started ...
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seaf-fsck.sh --repair
echo

# Run the garbage collection
echo Seafile cleanup started ...
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seaf-gc.sh
echo

# Clear expired session records
echo Clear expired session records ...
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seahub.sh python-env seahub/manage.py clearsessions
echo

# Clear outdated library records
echo Clear outdated library records ...
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seahub.sh python-env seahub/manage.py clear_invalid_repo_data
echo

echo Giving the server some time ...
sleep 10
echo

# Start the server again
echo Starting the Seafile server ...
sudo systemctl start seafile.service
sudo systemctl start seahub.service
echo

echo Seafile cleanup done!
echo


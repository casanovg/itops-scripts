#!/bin/bash

# Seafile storage mainteinance
# ......................................
# 2021-02-05 gustavo.casanova@gmail.com

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
LOG_PATH="/data/seafile-data/maintenance-log"
LOG_FILE="Seafile-Maintenance-$(date +%Y-%m-%d).log"

if [ ! -d $LOG_PATH ]; then
    mkdir -p $LOG_PATH
fi    

rm -rf $LOG_PATH/* 1>/dev/null 2>/dev/null

echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo "Seafile Maintenance Routine" 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo "===========================" 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo "START:" $(date "+%F %H:%M:%S") 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE

# Stop the server
echo Stopping the Seafile server ... 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo systemctl stop seafile.service 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo systemctl stop seahub.service 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE

echo Giving the server some time to shut down properly ... 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sleep 20

# Check and repair libraries
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seaf-fsck.sh --repair 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE

sleep 10

# Run the garbage collection
echo Seafile cleanup started ... 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seaf-gc.sh 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE

sleep 10

# Clear expired session records
echo Clear expired session records ... 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seahub.sh python-env $SEAFILE_PATH/seafile-server-latest/seahub/manage.py clearsessions 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
#echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE

sleep 10

# Start the server again
echo Starting the Seafile server ... 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo systemctl start seafile.service 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo systemctl start seahub.service 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE

# Clear outdated library records
echo Clear outdated library records ... 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
sudo -u $SERVICE_USER $SEAFILE_PATH/seafile-server-latest/seahub.sh python-env $SEAFILE_PATH/seafile-server-latest/seahub/manage.py clear_invalid_repo_data 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
#echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo "END:" $(date "+%F %H:%M:%S") 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo Seafile storage maintenance complete! 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE
echo 1>>$LOG_PATH/$LOG_FILE 2>>$LOG_PATH/$LOG_FILE

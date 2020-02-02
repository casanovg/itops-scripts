#!/bin/sh

#
# Start cloud file sync services
# ===============================================================
# 2020-02-02 gcasanova@hellermanntyton.com.ar
#

TARGET_CLOUD="iqn.2020-01.lan.htargentina:hta-mothership.cloud"
DEV_CLOUD="sdb1"
SERVER_CLOUD="10.6.17.40"

SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"

CL_DIR="/data/seafile-data"

# Connect HTA cloud iscsi target
if [ ! "$(cat /proc/partitions | grep -w "$DEV_CLOUD")" ]; then
    sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --login
    sleep 1
fi
# Mount HTA cloud Seafile storage
if [ "$(cat /proc/partitions | grep -w "$DEV_CLOUD")" ]; then
    if [ ! -z "$(ls -1 $CL_DIR | grep $ISCSI_WARNING)" ]; then
        sudo mount /dev/$DEV_CLOUD $CL_DIR
    fi
fi

sleep 5

# Start cloud services
for SERVICE in seafile seahub nginx; do
    if [ $(systemctl is-active ${SERVICE}) == "inactive" ]; then
        echo "Starting ${SERVICE} ..."
        sudo systemctl start ${SERVICE}
    else
        echo "Service ${SERVICE} already running ..."
    fi
done

# Services restart
# for ACTION in stop start ; do
#     for SERVICE in seafile seahub nginx; do
#       systemctl ${ACTION} ${SERVICE}
#     done
# done

#!/bin/sh

#
# Start cloud file sync services
# ...............................................................
# 2020-02-02 gcasanova@hellermanntyton.com.ar
#

TARGET_CLOUD="iqn.2020-01.lan.htargentina:hta-mothership.cloud"
DEV_CLOUD="sdb1"
SERVER_CLOUD="10.6.17.40"

TARGET_MATTERMOST="iqn.2020-03.lan.htargentina:hta-mothership.mattermost"
DEV_MATTERMOST="sdc1"
SERVER_MATTERMOST="10.6.17.40"

SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"

CL_DIR="/data/seafile-data"
MM_DIR="/data/mattermost-data"

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

# Connect HTA mattermost iscsi target
if [ ! "$(cat /proc/partitions | grep -w "$DEV_MATTERMOST")" ]; then
    sudo iscsiadm -m node --targetname $TARGET_MATTERMOST -p $SERVER_MATTERMOST --login
    sleep 1
fi
# Mount HTA Mattermost storage
if [ "$(cat /proc/partitions | grep -w "$DEV_MATTERMOST")" ]; then
    if [ ! -z "$(ls -1 $MM_DIR | grep $ISCSI_WARNING)" ]; then
        sudo mount /dev/$DEV_MATTERMOST $MM_DIR
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

# Start Mattermost service
if [ $(systemctl is-active mattermost.service) == "inactive" ]; then
    echo "Starting Mattermost ..."
    sudo systemctl start mattermost.service
else
    echo "Service Mattermost already running ..."
fi

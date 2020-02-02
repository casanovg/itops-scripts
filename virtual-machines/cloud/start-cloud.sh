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

CL_DIR="/data/cloud-disk"

# Connect HTA cloud iscsi target
if [ ! "$(cat /proc/partitions | grep -w "$DEV_CLOUD")" ]; then
    sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --login
    sleep 5
fi
# Mount HTA cloud Seafile storage
if [ "$(cat /proc/partitions | grep -w "$DEV_CLOUD")" ]; then
    if [ ! -z "$(ls -1 $CL_DIR | grep $ISCSI_WARNING)" ]; then
        sudo mount /dev/$DEV_CLOUD $CL_DIR
    fi
fi

# If is inactive, start service
if [ $(systemctl is-active nginx) == "inactive" ]; then
    echo "SHITLAND ACTIVATING"
else
    echo "IT'S ALLRIGHT ..."
fi

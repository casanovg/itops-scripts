#!/bin/sh

# Start Hibou Seafile cloud file sync services
# .............................................
# 2020-03-22 gustavo.casanova@gmail.com

TARGET_CLOUD="iqn.2020-02.lan.htargentina:hta-freenas:hibou"
DEV_CLOUD_UUID="790a7298-3169-44c6-b568-7e37d4d80b55" # Run "sudo blkid" to get this 
SERVER_CLOUD="10.6.17.70"

SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"

CL_DIR="/data/seafile-data"

# Start Hibou cloud services
echo ""
echo "Discovering available iSCSI targets disks on $SERVER_CLOUD"
echo "......................................................."

sudo iscsiadm -m discovery -t sendtargets -p $SERVER_CLOUD

echo ""
echo "Connecting iSCSI disks and mounting directories"
echo "..............................................."

# Connect Hibou cloud iscsi target
if [ -z "$(sudo blkid | grep "$DEV_CLOUD_UUID")" ]; then
    echo "Connecting \"$TARGET_CLOUD\" iSCSI disk ..." 
    sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --login
    sleep 2
else
    echo "\"$TARGET_CLOUD\" iSCSI disk already connected ..." 
fi

# Mount Hibou cloud Seafile storage
if [ ! -z "$(sudo blkid | grep "$DEV_CLOUD_UUID")" ]; then
    if [ ! -z "$(ls -1 $CL_DIR | grep $ISCSI_WARNING)" ]; then
	    echo "Mounting \"$CL_DIR\" directory ..."
        sudo mount /dev/disk/by-uuid/$DEV_CLOUD_UUID $CL_DIR
    else
	    echo "\"$CL_DIR\" directory already mounted ..."
    fi
else
    echo "Unable to mount \"$CL_DIR\", target iSCSI disconected!"
fi

sleep 5

# Start cloud services
echo ""
echo "Initializing Hibou Seafile cloud sync service"
echo "............................................."
for SERVICE in seafile seahub nginx; do
    if [ $(sudo systemctl is-active ${SERVICE}) != "active" ]; then
        echo "Starting ${SERVICE} ..."
        sudo systemctl start ${SERVICE}
    else
        echo "Service ${SERVICE} already running ..."
    fi
    sleep 1
done
echo ""


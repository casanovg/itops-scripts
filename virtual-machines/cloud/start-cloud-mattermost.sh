#!/bin/sh

# Start mattermost service
# ......................................
# 2021-02-05 gustavo.casanova@gmail.com

TARGET_MATTERMOST="iqn.2020-03.lan.htargentina:hta-mothership.mattermost"
DEV_MATTERMOST_UUID="e096e751-9598-40ac-83a8-833faddea058" # Run "sudo blkid" to get this 
SERVER_MATTERMOST="10.6.17.40"

SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"

MM_DIR="/data/mattermost-data"

# Start cloud services
echo ""
echo "Discovering available iSCSI targets disks on $SERVER_CLOUD"
echo "......................................................."

sudo iscsiadm -m discovery -t sendtargets -p $SERVER_CLOUD

echo ""
echo "Connecting iSCSI disks and mounting directories"
echo "..............................................."

# Connect HTA Mattermost iscsi target
if [ -z "$(sudo blkid | grep "$DEV_MATTERMOST_UUID")" ]; then
    echo "Connecting \"$TARGET_MATTERMOST\" iSCSI disk ..." 
    sudo iscsiadm -m node --targetname $TARGET_MATTERMOST -p $SERVER_MATTERMOST --login
    sleep 2
else
    echo "\"$TARGET_MATTERMOST\" iSCSI disk already connected ..."
fi

# Mount HTA Mattermost storage
if [ ! -z "$(sudo blkid | grep "$DEV_MATTERMOST_UUID")" ]; then
    if [ ! -z "$(ls -1 $MM_DIR | grep $ISCSI_WARNING)" ]; then
        echo "Mounting \"$MM_DIR\" directory ..."
        sudo mount /dev/disk/by-uuid/$DEV_MATTERMOST_UUID $MM_DIR
    else
        echo "\"$MM_DIR\" directory already mounted ..."
    fi
else
    echo "Unable to mount \"$MM_DIR\", target iSCSI disconected!"
fi

sleep 5

# Start Mattermost service
echo ""
echo "Initializing HTA Mattermost messaging service"
echo "............................................."
if [ $(sudo systemctl is-active mattermost.service) != "active" ]; then
    echo "Starting mattermost ..."
    sudo systemctl start mattermost.service
else
    echo "Service mattermost already running ..."
fi
echo ""
echo "Starting nginx web server ..."
sudo systemctl start nginx.service
echo ""


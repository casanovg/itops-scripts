#!/bin/sh

# Start cloud file sync services
# ......................................
# 2020-02-02 gustavo.casanova@gmail.com

TARGET_SEAFILE="iqn.2022-11.ar.hellermanntyton:hta-opportunity.seafile"
DEV_SEAFILE_UUID="7736fa41-9671-4cfe-88ca-5dd13497eaee" # Run "sudo blkid" to get this 
SERVER_SEAFILE="10.6.17.40"

TARGET_MATTERMOST="iqn.2022-11.ar.hellermanntyton:hta-opportunity.mattermost"
DEV_MATTERMOST_UUID="e096e751-9598-40ac-83a8-833faddea058" # Run "sudo blkid" to get this 
SERVER_MATTERMOST="10.6.17.40"

SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"

CL_DIR="/data/seafile-data"
MM_DIR="/data/mattermost-data"

# Start cloud services
echo ""
echo "Discovering available iSCSI targets disks on $SERVER_SEAFILE"
echo "......................................................."

sudo iscsiadm -m discovery -t sendtargets -p $SERVER_SEAFILE
# If Mattermost iSCSI drive is on a different server than the Seafile one, uncomment the following line
#sudo iscsiadm -m discovery -t sendtargets -p $SERVER_MATTERMOST

echo ""
echo "Connecting iSCSI disks and mounting directories"
echo "..............................................."

# Connect HTA Seafile cloud iscsi target
if [ -z "$(sudo blkid | grep "$DEV_SEAFILE_UUID")" ]; then
    echo "Connecting \"$TARGET_SEAFILE\" iSCSI disk ..." 
    sudo iscsiadm -m node --targetname $TARGET_SEAFILE -p $SERVER_SEAFILE --login
    sleep 2
else
    echo "\"$TARGET_SEAFILE\" iSCSI disk already connected ..." 
fi

# Mount HTA Seafile cloud storage
if [ ! -z "$(sudo blkid | grep "$DEV_SEAFILE_UUID")" ]; then
    if [ ! -z "$(ls -1 $CL_DIR | grep $ISCSI_WARNING)" ]; then
	echo "Mounting \"$CL_DIR\" directory ..."
        sudo mount /dev/disk/by-uuid/$DEV_SEAFILE_UUID $CL_DIR
    else
	echo "\"$CL_DIR\" directory already mounted ..."
    fi
else
    echo "Unable to mount \"$CL_DIR\", target iSCSI disconected!"
fi

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

# Start cloud services
echo ""
echo "Initializing HTA Seafile cloud sync service"
echo "..........................................."
for SERVICE in seafile seahub nginx; do
    if [ $(sudo systemctl is-active ${SERVICE}) != "active" ]; then
        echo "Starting ${SERVICE} ..."
        sudo systemctl start ${SERVICE}
    else
        echo "Service ${SERVICE} already running ..."
    fi
    sleep 1
done

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

#!/bin/sh

# Start fileserver shares and services
# ......................................
# 2019-12-30 gustavo.casanova@gmail.com

#TARGET_NETFILES="iqn.2019-12.lan.htargentina:hta-mothership.aleph"
TARGET_NETFILES="iqn.2022-11.ar.hellermanntyton:hta-opportunity.netfiles"
#TARGET_TAXPY="iqn.2019-12.lan.htargentina:hta-mothership.taxpy"
TARGET_TAXPY="iqn.2022-11.ar.hellermanntyton:hta-opportunity.taxpy"
DEV_NETFILES_UUID="593d18fd-6f1f-4011-ab82-ba6b370a5b1c"
DEV_NETFILES="sdb1"
DEV_TAXPY_UUID="783089f9-c09e-4700-b4ac-db76f07cbd3d"
DEV_TAXPY="sdc1"
SERVER_NETFILES="10.6.17.40"
SERVER_TAXPY="10.6.17.40"

BKP_DIR="/mnt-backintime"
SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"
EXCLUSION_1="BACKUP-README"
EXCLUSION_2="hta-enterprise"

FS_DIR="/data/netfiles-disk"
TP_DIR="/data/taxpy-disk"

# Discover available iSCSI targets disks
sudo iscsiadm -m discovery -t sendtargets -p $SERVER_NETFILES

# Connect HTA files and users shares iscsi targets
if [ ! "$(cat /proc/partitions | grep -w "$DEV_NETFILES")" ]; then
    sudo iscsiadm -m node --targetname $TARGET_NETFILES -p $SERVER_NETFILES --login
    sleep 1
else
    echo ""
    echo "\"$TARGET_NETFILES\" already connected ..."
fi

# Mount HTA files and users shares
if [ "$(cat /proc/partitions | grep -w "$DEV_NETFILES")" ]; then
    if [ ! -z "$(ls -1 $FS_DIR | grep $ISCSI_WARNING)" ]; then
        sudo mount /dev/disk/by-uuid/$DEV_NETFILES_UUID $FS_DIR
    else
	echo ""
	echo "\"$FS_DIR\" already mounted ..."
    fi
else
    echo ""
    echo "Unable to mount \"$FS_DIR\" iSCSI disk disconnected ..."
fi

# Connect finance tax payers records iscsi target
if [ ! "$(cat /proc/partitions | grep -w "$DEV_TAXPY")" ]; then
    sudo iscsiadm -m node --targetname $TARGET_TAXPY -p $SERVER_TAXPY --login
    sleep 1
else
    echo ""
    echo "\"$TARGET_TAXPY\" already connected ..."
fi

# Mount finance tax payers records share
if [ "$(cat /proc/partitions | grep -w "$DEV_TAXPY")" ]; then
    if [ ! -z "$(ls -1 $TP_DIR | grep $ISCSI_WARNING)" ]; then
        sudo mount /dev/disk/by-uuid/$DEV_TAXPY_UUID $TP_DIR
    fi
else
    echo ""
    echo "Unable to mount \"$TP_DIR\" iSCSI disk disconnected ..."
fi

# Mount physical server shares to back them up with Back-in-Time
echo ""
for SHARE in $(ls -1 $BKP_DIR); do
    if [ "$SHARE" != "$EXCLUSION_1" ] && [ "$SHARE" != "$EXCLUSION_2" ]; then
        if [ ! -z "$(ls -1 $BKP_DIR/"$SHARE" | grep $SHARE_WARNING)" ]; then
	    # Patch to mount the SQL Server Windows share
	    # ...........................................
	    sudo chmod u+s /bin/mount
	    sudo chmod u+s /bin/umount
	    sudo chmod u+s /usr/sbin/mount.cifs
	    WINSHARES_USR="$(sudo cat ~/.windowsshares-usr | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')"
	    WINSHARES_PWD="$(sudo cat ~/.windowsshares-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')"
	    if [ "$SHARE" == "sqlserver-backup" ]; then
		sudo mount -t cifs //HTA-DYP/SQLServer-Backup$ /mnt-backintime/sqlserver-backup -o username="$WINSHARES_USR",password="$WINSHARES_PWD"
	    fi
	    # ...........................................
	    # End patch
            echo "Mounting $SHARE ..."
            mount $BKP_DIR/"$SHARE"
            echo ""
        else
            echo "$SHARE already mounted!"
            echo ""
        fi
    fi
    sleep 2
done

# Authenticate with AD domain controller and start Samba shares
if [ ! "$(sudo wbinfo --ping-dc 2>>/dev/null | grep -w "succeeded")" ]; then
   ~/itops-scripts/virtual-machines/fileserver/fs-start.sh
   sleep 1
   #~/itops-scripts/virtual-machines/fileserver/fs-stop.sh
   #sleep 1
   #~/itops-scripts/virtual-machines/fileserver/fs-start.sh
else
    echo "Samba service already active!"
fi
echo ""

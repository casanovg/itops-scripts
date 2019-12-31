#!/bin/sh

#
# Start fileserver shares and services
# ====================================
# 2019-12-30 Gustavo Casanova
#

TARGET_ALEPH="iqn.2019-12.lan.htargentina:hta-mothership.aleph"
TARGET_TAXPY="iqn.2019-12.lan.htargentina:hta-mothership.taxpy"
DEV_ALEPH="sdb1"
DEV_TAXPY="sdc1"
SERVER_ALEPH="10.6.17.40"
SERVER_TAXPY="10.6.17.40"

BKP_DIR="/mnt-backintime"
SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"
EXCLUSION_1="BACKUP-README"
EXCLUSION_2="hta-enterprise"

FS_DIR="/data/aleph-disk"
TP_DIR="/data/taxpy-disk"

# Connect HTA files and users shares iscsi target
if [ ! "$(cat /proc/partitions | grep -w "$DEV_ALEPH")" ]; then
    sudo iscsiadm -m node --targetname $TARGET_ALEPH -p $SERVER_ALEPH --login
    sleep 1
fi
# Mount HTA files and users shares
if [ "$(cat /proc/partitions | grep -w "$DEV_ALEPH")" ]; then
    if [ ! -z "$(ls -1 $FS_DIR | grep $ISCSI_WARNING)" ]; then
        sudo mount /dev/$DEV_ALEPH $FS_DIR
    fi
fi

# Connect finance tax payers records iscsi target
if [ ! "$(cat /proc/partitions | grep -w "$DEV_TAXPY")" ]; then
    sudo iscsiadm -m node --targetname $TARGET_TAXPY -p $SERVER_TAXPY --login
    sleep 1
fi
# Mount finance tax payers records share
if [ "$(cat /proc/partitions | grep -w "$DEV_TAXPY")" ]; then
    if [ ! -z "$(ls -1 $TP_DIR | grep $ISCSI_WARNING)" ]; then
        sudo mount /dev/$DEV_TAXPY $TP_DIR
    fi
fi

# Mount bare-metal server shares to back them up with Back-in-Time
echo ""
for SHARE in $(ls -1 $BKP_DIR); do
    if [ "$SHARE" != "$EXCLUSION_1" ] && [ "$SHARE" != "$EXCLUSION_2" ]; then
        if [ ! -z "$(ls -1 $BKP_DIR/"$SHARE" | grep $SHARE_WARNING)" ]; then
            echo "Mounting $SHARE ..."
            mount $BKP_DIR/"$SHARE"
            echo ""
            #else
            #echo "$SHARE already mounted!"
            #echo ""
        fi
    fi
done

# Authenticate with AD domain controller and start Samba shares
if [ ! "$(wbinfo --ping-dc 2>>/dev/null | grep -w "succeeded")" ]; then
    #echo "CHONGA MUST SAMBAR"
   ~/itops-scripts/fileserver-vm/fs-start.sh
   sleep 1
   ~/itops-scripts/fileserver-vm/fs-stop.sh
   sleep 1
   ~/itops-scripts/fileserver-vm/fs-start.sh
#else
    #echo "NADA"
fi

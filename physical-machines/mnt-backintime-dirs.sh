#!/bin/sh

# Mount BackInTime directories
# ......................................
# 2023-07-27 gustavo.casanova@gmail.com

SERVER_NETFILES="10.6.17.40"
SERVER_TAXPY="10.6.17.40"

BKP_DIR="/mnt-backintime"
SHARE_WARNING="SHARE_NOT_MOUNTED"
ISCSI_WARNING="DISK_NOT_MOUNTED"
EXCLUSION_1="BACKUP-README"
EXCLUSION_2="hta-enterprise"

FS_DIR="/data/netfiles-disk"
TP_DIR="/data/taxpy-disk"


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


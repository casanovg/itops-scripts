#!/bin/sh

# Mount Off-site directories
# ......................................
# 2023-09-21 gustavo.casanova@gmail.com

BKP_DIR="/off-site"
SHARE_WARNING="SHARE_NOT_MOUNTED"

# Mount physical server shares for off-site backup
echo ""
if [ ! -z "$(ls -1 $BKP_DIR | grep $SHARE_WARNING)" ]; then
    # Patch to mount the SQL Server Windows share
    # ...........................................
    sudo chmod u+s /bin/mount
    sudo chmod u+s /bin/umount
    sudo chmod u+s /usr/sbin/mount.cifs
    # ...........................................
    # End patch
    echo "Mounting $BKP_DIR ..."
    mount $BKP_DIR
    echo ""
else
    echo "$BKP_DIR already mounted!"
    echo ""
fi


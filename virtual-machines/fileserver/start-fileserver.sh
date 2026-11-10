#!/bin/sh

# Start fileserver shares and services
# ......................................
# 2019-12-30 gustavo.casanova@gmail.com
# 2025-12-17 Updated with dynamic wait for iSCSI devices
# 2026-11-09 Detect disks by UUID (sd letters shift across relogins);
#            skip login when a session already exists (avoid duplicates).

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

# Function to wait for device to be available
wait_for_device() {
    local UUID=$1
    local DEVICE_NAME=$2
    local MAX_WAIT=60
    local WAITED=0
    
    echo "Waiting for device $DEVICE_NAME (UUID: $UUID) to be available..."
    while [ $WAITED -lt $MAX_WAIT ]; do
        if [ -e "/dev/disk/by-uuid/$UUID" ]; then
            echo "Device $DEVICE_NAME is ready after ${WAITED}s"
            return 0
        fi
        sleep 2
        WAITED=$((WAITED + 2))
    done
    
    echo "WARNING: Device $DEVICE_NAME did not appear after ${MAX_WAIT}s"
    return 1
}

# Disk is present when its filesystem UUID resolves, whatever sd name
# the kernel assigned on this login (sdb1/sdc1 are NOT stable).
disk_present() {
    [ -e "/dev/disk/by-uuid/$1" ]
}

# 2026-11-10 Release stale mounts left by an iSCSI session loss + relogin
#            (fresh device refuses to mount with "XFS: duplicate UUID").
# An iSCSI session already exists for the given target IQN.
session_active() {
    sudo iscsiadm -m session 2>/dev/null | grep -q "$1"
}

# Drop a mountpoint left stale by an iSCSI session loss.
# Only provably-stale mounts are touched; healthy mounts are never modified.
# Returns 0 when the mountpoint is free (or was never mounted), 1 when it
# could not be released yet (busy) - the caller must skip the mount and let
# a later tick retry.
release_stale_mount() {
    local MNT=$1
    local UUID=$2
    local SRC CUR BASE FLAG
    SRC="$(findmnt -n -o SOURCE "$MNT" 2>/dev/null)" || return 0
    [ -n "$SRC" ] || return 0
    case "$SRC" in /dev/*) ;; *) return 0 ;; esac
    CUR="$(readlink -f /dev/disk/by-uuid/$UUID 2>/dev/null)"
    if [ "$SRC" = "$CUR" ] && [ -e "$SRC" ]; then
        if ls "$MNT" >/dev/null 2>&1; then
            return 0
        fi
        # Same device path but unreadable: only safe to release if the
        # kernel already declared this filesystem dead (avoids ripping out
        # a live mount during a transient I/O hiccup).
        BASE="${SRC##*/}"
        if journalctl --no-pager -b 0 -k 2>/dev/null | grep -q "XFS ($BASE).*Shutting down filesystem"; then
            echo "Stale mount on $MNT ($SRC shut down by kernel), releasing..."
        else
            echo "WARNING: $MNT unreadable but $SRC looks live, leaving for next tick ..."
            return 1
        fi
    else
        echo "Stale mount on $MNT (was $SRC, device now ${CUR:-missing}), releasing..."
    fi
    # Fast path: clean unmount (no open files).
    if sudo umount "$MNT" 2>/dev/null; then
        sleep 1
        findmnt "$MNT" >/dev/null 2>&1 || return 0
    fi
    # Slow path: open files (typically smbd) keep even a lazy-detached
    # mount active, which still blocks remounting ("duplicate UUID").
    FLAG="/tmp/.stale-bounce-$(echo "$MNT" | tr -c 'a-zA-Z0-9' '_')"
    if [ -e "$FLAG" ]; then
        echo "WARNING: $MNT still busy (samba bounce already done this boot), retry next tick ..."
        return 1
    fi
    touch "$FLAG"
    echo "Mount $MNT busy, restarting samba to release open files..."
    sudo systemctl stop smb nmb 2>/dev/null
    trap 'sudo systemctl start smb nmb 2>/dev/null' EXIT HUP INT TERM
    sleep 3
    sudo umount "$MNT" 2>/dev/null || sudo umount -l "$MNT" 2>/dev/null
    sleep 2
    sudo systemctl start smb nmb 2>/dev/null
    trap - EXIT HUP INT TERM
    if findmnt "$MNT" >/dev/null 2>&1; then
        echo "WARNING: $MNT still busy after samba bounce, retry next tick ..."
        return 1
    fi
    return 0
}

# Discover available iSCSI targets disks
sudo iscsiadm -m discovery -t sendtargets -p $SERVER_NETFILES

# Connect HTA files and users shares iscsi targets
if ! disk_present "$DEV_NETFILES_UUID"; then
    if ! session_active "$TARGET_NETFILES"; then
        echo "Connecting to $TARGET_NETFILES..."
        sudo iscsiadm -m node --targetname $TARGET_NETFILES -p $SERVER_NETFILES --login
    else
        echo "Session $TARGET_NETFILES exists, waiting for device..."
    fi
    wait_for_device "$DEV_NETFILES_UUID" "$DEV_NETFILES"
else
    echo ""
    echo "\"$TARGET_NETFILES\" already connected ..."
fi

# Mount HTA files and users shares
if disk_present "$DEV_NETFILES_UUID"; then
    if release_stale_mount "$FS_DIR" "$DEV_NETFILES_UUID"; then
        if [ ! -z "$(ls -1 $FS_DIR 2>/dev/null | grep $ISCSI_WARNING)" ]; then
            echo "Mounting $FS_DIR..."
            sudo mount /dev/disk/by-uuid/$DEV_NETFILES_UUID $FS_DIR
        else
            echo ""
            echo "\"$FS_DIR\" already mounted ..."
        fi
    else
        echo ""
        echo "WARNING: \"$FS_DIR\" mount blocked, will retry next tick ..."
    fi
else
    echo ""
    echo "Unable to mount \"$FS_DIR\" iSCSI disk disconnected ..."
fi

# Connect finance tax payers records iscsi target
if ! disk_present "$DEV_TAXPY_UUID"; then
    if ! session_active "$TARGET_TAXPY"; then
        echo "Connecting to $TARGET_TAXPY..."
        sudo iscsiadm -m node --targetname $TARGET_TAXPY -p $SERVER_TAXPY --login
    else
        echo "Session $TARGET_TAXPY exists, waiting for device..."
    fi
    wait_for_device "$DEV_TAXPY_UUID" "$DEV_TAXPY"
else
    echo ""
    echo "\"$TARGET_TAXPY\" already connected ..."
fi

# Mount finance tax payers records share
if disk_present "$DEV_TAXPY_UUID"; then
    if release_stale_mount "$TP_DIR" "$DEV_TAXPY_UUID"; then
        if [ ! -z "$(ls -1 $TP_DIR 2>/dev/null | grep $ISCSI_WARNING)" ]; then
            echo "Mounting $TP_DIR..."
            sudo mount /dev/disk/by-uuid/$DEV_TAXPY_UUID $TP_DIR
        fi
    else
        echo ""
        echo "WARNING: \"$TP_DIR\" mount blocked, will retry next tick ..."
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

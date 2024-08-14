#!/bin/sh

# Backup Ty-Mail users' mailboxes
# ......................................
# 2024-08-14 gustavo.casanova@gmail.com

MAILBX_DIR="/data/mailusr-home"
BACKUP_DIR="/data/mail-bkp"
BKP_USR="netbackup"
BKP_GRP="wheel"

INCLUDE01="Maildir"

EXCLUDE01="spamd"
EXCLUDE02="netbackup"
EXCLUDE03=".bash*"
EXCLUDE04=".X*"

# Stop Mail Server services
echo ""
echo "Stopping Mail Server services ..."
~/itops-scripts/virtual-machines/mail/mx-stop.sh

echo ""
echo "Backing up all mailboxes ..."
echo ""
sudo rsync -r -a --info=progress2 --delete --delete-excluded --human-readable --include=$INCLUDE01 --exclude=$EXCLUDE01 --exclude=$EXCLUDE02 --exclude=$EXCLUDE03 --exclude=$EXCLUDE04 $MAILBX_DIR/* $BACKUP_DIR/.

echo ""
echo "Changing backup files ownership to $BKP_USR ..."

sudo chown -R $BKP_USR:$BKP_GRP $BACKUP_DIR

echo ""
echo "Starting Mail Server services"
~/itops-scripts/virtual-machines/mail/mx-start.sh


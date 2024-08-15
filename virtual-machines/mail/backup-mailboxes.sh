#!/bin/sh

# Backup TY-Mail users' mailboxes
# ......................................
# 2024-08-14 gustavo.casanova@gmail.com

MAILBX_DIR="/data/mailusr-home"
BACKUP_DIR="/data/mailusr-backup"
BKP_USR="netbackup"
BKP_GRP="wheel"

INC_01="Maildir"

EXC_01="spamd"
EXC_02="netbackup"
EXC_03=".bash*"
EXC_04=".X*"

# Stop Mail Server services
echo ""
echo "Stopping Mail Server services ..."
~/itops-scripts/virtual-machines/mail/mx-stop.sh

echo ""
echo "Backing up all mailboxes ..."
echo ""
sudo rsync -r -a -v --info=progress2 --times --devices --specials --hard-links --links --perms --executability --group --owner --delete --delete-excluded --human-readable --include=$INC_01 --exclude=$EXC_01 --exclude=$EXC_02 --exclude=$EXC_03 --exclude=$EXC_04 $MAILBX_DIR/ $BACKUP_DIR/

echo ""
echo "Changing backup files ownership to $BKP_USR ..."

sudo chown -R $BKP_USR:$BKP_GRP $BACKUP_DIR

echo ""
echo "Starting Mail Server services"
~/itops-scripts/virtual-machines/mail/mx-start.sh


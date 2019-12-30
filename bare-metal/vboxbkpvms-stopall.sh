#!/bin/sh

#
# VBoxBkpVMs-StopAll
# ===========================
# 2018-04-22 Gustavo Casanova
#

BACKUP_DIR='/data/VirtualBox-Exports'
DATE_NOW=$(date -I --date='now')
LOG_FILE='/data/VirtualBox-Exports/Log/vboxbackup.log'
ESSENTIAL_SERVICE=''
IFS=$'\n'

echo "********************************************************************************"
echo "* $DATE_NOW * Backing-up >>> $(hostname -s | tr [a-z] [A-Z]) <<< VirtualBox Virtual Machines"
echo "********************************************************************************"

for VM in $(cat ~/ActiveVMs); do
	echo "--------------------------------------------------------------------------------"
	echo "Shutting >> "$VM" << down on $(date) ..."
	~/itops-scripts/bare-metal/vbox-off.sh "$VM"
done
for VM in $(cat ~/ActiveVMs); do
	echo "--------------------------------------------------------------------------------"
	echo "Removing old "$VM" backups ..."
	find $BACKUP_DIR -type f -mtime +0 -name "$VM*"
	find $BACKUP_DIR -type f -mtime +0 -name "$VM*" -execdir rm -- '{}' \;
	sleep 3
	echo "Backing-up "$VM" to file $BACKUP_DIR/"$VM" $DATE_NOW.ova"
	rm -f $BACKUP_DIR/"$VM $DATE_NOW.ova" 2>>/dev/null
	vboxmanage export "$VM" --output $BACKUP_DIR/"$VM $DATE_NOW.ova" --ovf20
	chown netbackup:wheel $BACKUP_DIR/"$VM $DATE_NOW.ova"
	echo ""
	sleep 3
	if [ "$VM" == "$ESSENTIAL_SERVICE" ]; then
		echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
		echo "|| "$VM" runs essential services, starting it now ..."
		echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
		~/itops-scripts/bare-metal/vbox-on.sh "$VM"
		sleep 5
	fi
done
for VM in $(cat ~/ActiveVMs); do
	if [ "$VM" != "$ESSENTIAL_SERVICE" ]; then
		echo "Restarting >> "$VM" << on $(date) ..."
		~/itops-scripts/bare-metal/vbox-on.sh "$VM"
		sleep 60
	fi
done
echo "--------------------------------------------------------------------------------"

echo "********************************************************************************"
echo "* $DATE_NOW * >>> $(hostname -s | tr [a-z] [A-Z]) <<< VirtualBox Backup Complete"
echo "********************************************************************************"
echo "[]"
echo "[]"
echo "[]"

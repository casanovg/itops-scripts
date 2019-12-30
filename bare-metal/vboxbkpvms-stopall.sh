#!/bin/sh

#
# VBoxBkpVMs-StopAll
# ===========================
# 2018-04-22 Gustavo Casanova
#

BackupDir='/data/VirtualBox-Exports'
DateNow=$(date -I --date='now')
LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log'
EssentialService=''
IFS=$'\n'

echo "********************************************************************************"
echo "* $DateNow * Backing-up >>> $(hostname -s | tr [a-z] [A-Z]) <<< VirtualBox Virtual Machines"
echo "********************************************************************************"

for VM in $(cat ~/ActiveVMs); do
	echo "--------------------------------------------------------------------------------"
	echo "Shutting >> "$VM" << down on $(date) ..."
	~/itops-scripts/bare-metal/vbox-off.sh "$VM"
done
for VM in $(cat ~/ActiveVMs); do
	echo "--------------------------------------------------------------------------------"
	echo "Removing old "$VM" backups ..."
	find $BackupDir -type f -mtime +0 -name "$VM*"
	find $BackupDir -type f -mtime +0 -name "$VM*" -execdir rm -- '{}' \;
	sleep 3
	echo "Backing-up "$VM" to file $BackupDir/"$VM" $DateNow.ova"
	rm -f $BackupDir/"$VM $DateNow.ova" 2>>/dev/null
	vboxmanage export "$VM" --output $BackupDir/"$VM $DateNow.ova" --ovf20
	chown netbackup:wheel $BackupDir/"$VM $DateNow.ova"
	echo ""
	sleep 3
	if [ "$VM" == "$EssentialService" ]; then
		echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
		echo "|| "$VM" runs essential services, starting it now ..."
		echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
		~/itops-scripts/bare-metal/vbox-on.sh "$VM"
		sleep 5
	fi
done
for VM in $(cat ~/ActiveVMs); do
	if [ "$VM" != "$EssentialService" ]; then
		echo "Restarting >> "$VM" << on $(date) ..."
		~/itops-scripts/bare-metal/vbox-on.sh "$VM"
		sleep 60
	fi
done
echo "--------------------------------------------------------------------------------"

echo "********************************************************************************"
echo "* $DateNow * >>> $(hostname -s | tr [a-z] [A-Z]) <<< VirtualBox Backup Complete"
echo "********************************************************************************"
echo "[]"
echo "[]"
echo "[]"

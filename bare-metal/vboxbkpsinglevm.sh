#!/bin/sh

#
# VBoxBkpSingleVM
# ===========================
# 2018-06-04 Gustavo Casanova
#

VM=$1
BackupDir='/data/VirtualBox-Exports'
DateNow=$(date -I --date='now')
LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log'

if [ -z $1 ]; then
	echo ""
	echo "Usage: vboxbkpsinglevm <VirtualBox VM Name>"
	echo ""
	echo " i.e.: vboxbkpsinglevm \"HTA-NetPal\""
	echo ""
	exit 1
else
	echo ""
	echo "--------------------------------------------------------------------------------"
	echo "- Starting >> $VM << VM Backup on $(date)"
	echo "Trying to shutdown" $VM on $DateNow "..."
	while [ $(vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}' | grep $VM) ]; do
		vboxmanage controlvm $VM acpipowerbutton 2>>/dev/null
		sleep 2
		vboxmanage controlvm $VM acpipowerbutton 2>>/dev/null
		echo -n "."
		sleep 5
	done
	echo""
	echo "VM" $VM "succesfully stopped."
	echo "Backing-up" $VM to file $BackupDir/"$VM $DateNow.ova"
	rm -f $BackupDir/"$VM $DateNow.ova" 2>>/dev/null
	vboxmanage export $VM --output $BackupDir/"$VM $DateNow.ova" --ovf20
	chown netbackup:wheel $BackupDir/"$VM $DateNow.ova"
	sleep 3
	echo "Restarting" $VM "..."
	vboxmanage startvm $VM --type headless
	#echo "Removing old $VM backups ...";
	#find $BackupDir -type f -mtime +0 -name "$VM*";
	#find $BackupDir -type f -mtime +0 -name "$VM*" -execdir rm -- '{}' \;
	#sleep 5;
	echo "- Finishing >> $VM << VM Backup on $(date)"
	echo "--------------------------------------------------------------------------------"
fi

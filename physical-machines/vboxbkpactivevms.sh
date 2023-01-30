#!/bin/sh

# Active virtual machines backup script
# ......................................
# 2018-05-19 gustavo.casanova@gmail.com

BackupDir='/data/VirtualBox-Exports'
DateNow=$(date -I --date='now')
LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log'

echo "********************************************************************************"
echo "* $DateNow * Backing-up  >>> $(hostname -s | tr [a-z] [A-Z]) <<< VirtualBox Virtual Machines"
echo "********************************************************************************"

for virtualmachine in $(cat /root/ActiveVMs); do
	echo "--------------------------------------------------------------------------------"
	echo "- Starting >> $virtualmachine << VM Backup on $(date)"
	echo "Trying to shutdown" $virtualmachine on $DateNow "..."
	while [ $(vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}' | grep $virtualmachine) ]; do
		vboxmanage controlvm $virtualmachine acpipowerbutton 2>>/dev/null
		sleep 2
		vboxmanage controlvm $virtualmachine acpipowerbutton 2>>/dev/null
		echo -n "."
		sleep 60
	done
	echo""
	echo "VM" $virtualmachine "succesfully stopped."
	echo "Removing old $virtualmachine backups ..."
	find $BackupDir -type f -mtime +0 -name "$virtualmachine*"
	find $BackupDir -type f -mtime +0 -name "$virtualmachine*" -execdir rm -- '{}' \;
	sleep 3
	echo "Backing-up" $virtualmachine to file $BackupDir/"$virtualmachine $DateNow.ova"
	rm -f $BackupDir/"$virtualmachine $DateNow.ova" 2>>/dev/null
	vboxmanage export $virtualmachine --output $BackupDir/"$virtualmachine $DateNow.ova" --ovf20
	chown netbackup:wheel $BackupDir/"$virtualmachine $DateNow.ova"
	sleep 3
	echo "Restarting" $virtualmachine "..."
	vboxmanage startvm $virtualmachine --type headless
	sleep 5
	echo "- Finishing >> $virtualmachine << VM Backup on $(date)"
	echo "--------------------------------------------------------------------------------"
done

echo "********************************************************************************"
echo "* $DateNow * >>> $(hostname -s | tr [a-z] [A-Z]) <<< VirtualBox Backup Complete"
echo "********************************************************************************"
echo "[]"
echo "[]"
echo "[]"

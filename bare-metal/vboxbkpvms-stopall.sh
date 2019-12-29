#!/bin/sh

#
# VBoxBkpVMs-StopAll
# ===========================
# 2018-04-22 Gustavo Casanova
#

BackupDir='/data/VirtualBox-Exports';
DateNow=`date -I --date='now'`;
LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log';
EssentialService='';

echo "********************************************************************************";
echo "* $DateNow * Backing-up >>> `hostname -s | tr [a-z] [A-Z]` <<< VirtualBox Virtual Machines";
echo "********************************************************************************";

for VM in "`cat ~/ActiveVMs`"
do
	echo "--------------------------------------------------------------------------------";
    	echo "Trying to shutdown >> "$VM" << VM  on `date` ...";

    	while [ `vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "$VM"` ]
    	do
        	vboxmanage controlvm "$VM" acpipowerbutton 2>>/dev/null;
        	sleep 2;
        	vboxmanage controlvm "$VM" acpipowerbutton 2>>/dev/null;
        	echo -n ".";
        	sleep 3;
    	done
    	echo"";
    	echo ""$VM" virtual machine succesfully stopped.";
done
for VM in "`cat ~/ActiveVMs`"
do
    	echo "--------------------------------------------------------------------------------";
    	echo "Removing old "$VM" backups ...";
    	find $BackupDir -type f -mtime +0 -name "$VM*";
    	find $BackupDir -type f -mtime +0 -name "$VM*" -execdir rm -- '{}' \;
    	sleep 3;
    	echo "Backing-up "$VM" to file $BackupDir/"$VM" $DateNow.ova";
    	rm -f $BackupDir/"$VM $DateNow.ova" 2>>/dev/null;
    	#vboxmanage export "$VM" --output $BackupDir/"$VM $DateNow.ova" --ovf20;
    	chown netbackup:wheel $BackupDir/"$VM $DateNow.ova";
    	sleep 3;
    	if [ "$VM" == "$EssentialService" ]
    	then
      		echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
      		echo "|| "$VM" VM runs essential services, starting it now ...";
      		echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
      		vboxmanage startvm "$VM" --type headless;
      		sleep 5;
    	fi
done
for VM in "`cat ~/ActiveVMs`"
do
    	if [ "$VM" != "$EssentialService" ]
    	then
      		echo "Restarting >> "$VM" << on `date` ...";
      		vboxmanage startvm "$VM" --type headless;
      	sleep 60;
    	fi
done
echo "--------------------------------------------------------------------------------";

echo "********************************************************************************";
echo "* $DateNow * >>> `hostname -s | tr [a-z] [A-Z]` <<< VirtualBox Backup Complete";
echo "********************************************************************************";
echo "[]";
echo "[]";
echo "[]";


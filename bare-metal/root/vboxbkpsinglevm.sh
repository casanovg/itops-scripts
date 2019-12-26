#!/bin/sh

#
# VBoxBkpSingleVM
# ===========================
# 2018-06-04 Gustavo Casanova
#

virtualmachine=$1
BackupDir='/data/VirtualBox-Exports'
DateNow=`date -I --date='now'`
LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log'

if [ -z $1 ]; then
  echo ""
  echo "Usage: vboxbkpsinglevm <VirtualBox VM Name>";
  echo "";
  echo " i.e.: vboxbkpsinglevm \"HTA-NetPal\"";
  echo "";
  exit 1;
else
  echo "";
  echo "--------------------------------------------------------------------------------";
  echo "- Starting >> $virtualmachine << VM Backup on `date`";
  echo "Trying to shutdown" $virtualmachine on $DateNow "...";
  while [ `vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}' | grep $virtualmachine` ]
    do
      vboxmanage controlvm $virtualmachine acpipowerbutton 2>>/dev/null;
      sleep 2;
      vboxmanage controlvm $virtualmachine acpipowerbutton 2>>/dev/null;
      echo -n ".";
      sleep 5;
    done
    echo"";
    echo "VM" $virtualmachine "succesfully stopped.";
    echo "Backing-up" $virtualmachine to file $BackupDir/"$virtualmachine $DateNow.ova";
    rm -f $BackupDir/"$virtualmachine $DateNow.ova" 2>>/dev/null;
    vboxmanage export $virtualmachine --output $BackupDir/"$virtualmachine $DateNow.ova" --ovf20;
    chown netbackup:wheel $BackupDir/"$virtualmachine $DateNow.ova";
    sleep 3;
    echo "Restarting" $virtualmachine "...";
    vboxmanage startvm $virtualmachine --type headless;
    #echo "Removing old $virtualmachine backups ...";
    #find $BackupDir -type f -mtime +0 -name "$virtualmachine*";
    #find $BackupDir -type f -mtime +0 -name "$virtualmachine*" -execdir rm -- '{}' \;
    #sleep 5;
    echo "- Finishing >> $virtualmachine << VM Backup on `date`";
    echo "--------------------------------------------------------------------------------";
fi

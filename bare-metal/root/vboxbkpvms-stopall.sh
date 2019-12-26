#!/bin/sh

#
# VBoxBkpVMs-StopAll
# ===========================
# 2018-04-22 Gustavo Casanova
#

BackupDir='/data/VirtualBox-Exports'
DateNow=`date -I --date='now'`
LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log'
EssentialService=''

echo "********************************************************************************";
echo "* $DateNow * Backing-up  >>> `hostname -s | tr [a-z] [A-Z]` <<< VirtualBox Virtual Machines";
echo "********************************************************************************";

for virtualmachine in `cat /root/ActiveVMs`
  do
    echo "--------------------------------------------------------------------------------";
    echo "Trying to shutdown >> $virtualmachine << VM  on `date` ...";
    while [ `vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}' | grep $virtualmachine` ]
      do
        vboxmanage controlvm $virtualmachine acpipowerbutton 2>>/dev/null;
        sleep 2;
        vboxmanage controlvm $virtualmachine acpipowerbutton 2>>/dev/null;
        echo -n ".";
        sleep 3;
      done
      echo"";
      echo "VM" $virtualmachine "succesfully stopped.";
  done
for virtualmachine in `cat /root/ActiveVMs`
  do
    echo "--------------------------------------------------------------------------------";
    echo "Removing old $virtualmachine backups ...";
    find $BackupDir -type f -mtime +0 -name "$virtualmachine*";
    find $BackupDir -type f -mtime +0 -name "$virtualmachine*" -execdir rm -- '{}' \;
    sleep 3;
    echo "Backing-up" $virtualmachine to file $BackupDir/"$virtualmachine $DateNow.ova";
    rm -f $BackupDir/"$virtualmachine $DateNow.ova" 2>>/dev/null;
    vboxmanage export $virtualmachine --output $BackupDir/"$virtualmachine $DateNow.ova" --ovf20;
    chown netbackup:wheel $BackupDir/"$virtualmachine $DateNow.ova";
    sleep 3;
    if [ "$virtualmachine" == "$EssentialService" ]
    then
      echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
      echo "|| $virtualmachine VM runs essential services, starting it now ...";
      echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
      vboxmanage startvm $virtualmachine --type headless;
      sleep 5;
    fi
  done
for virtualmachine in `cat /root/ActiveVMs`
  do

    if [ "$virtualmachine" != "$EssentialService" ]
    then
      echo "Restarting >> $virtualmachine << on `date` ...";
      vboxmanage startvm $virtualmachine --type headless;
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

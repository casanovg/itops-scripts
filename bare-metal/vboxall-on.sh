#!/bin/sh

# *****************************************************
# * Script to power on all necessary virtual machines *
# * ================================================= *
# * 2018-03-15 Gustavo Casanova                       *
# * gcasanova@hellermanntyton.com.ar                  *
# *****************************************************

VMFile='/home/netbackup/ActiveVMs'

while read virtualmachine
  do
    echo ""
    vboxmanage startvm $virtualmachine --type headless
    echo "Waiting 2 minutes for VM's services startup ..."
    sleep 120
  done < $VMFile


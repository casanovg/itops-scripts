#!/bin/sh

# ****************************************************
# * Script to power off all running virtual machines *
# * ================================================ *
# * 2018-03-15 Gustavo Casanova                      *
# * gcasanova@hellermanntyton.com.ar                 *
# ****************************************************

for virtualmachine in `vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}'`;
  do
    echo ""
    echo "$virtualmachine Server active, sending shutdown signal ...";
    vboxmanage controlvm $virtualmachine acpipowerbutton;
    sleep 2;
    vboxmanage controlvm $virtualmachine acpipowerbutton;
    sleep 60;
  done


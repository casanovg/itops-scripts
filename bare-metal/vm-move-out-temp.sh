#!/bin/sh

# Script to move a virtual machine to anothe bare-metal server
# .............................................................
# 2020-01-16 gcasanova@hellermanntyton.com.ar

VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
DEST=$2
VBOX_PATH="/data/VirtualBox-VMs"

     #vboxmanage list vms | gawk -F\" '{print $(NF-1)}'
     #~/itops-scripts/bare-metal/vm-off.sh "$VM"
     rsync -r -a --relative "$VBOX_PATH"/"$VM" --info=progress2 $DEST:/


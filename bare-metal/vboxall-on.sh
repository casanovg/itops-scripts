#!/bin/sh

# *****************************************************
# * Script to power on all necessary virtual machines *
# * ================================================= *
# * 2018-03-15 Gustavo Casanova                       *
# * gcasanova@hellermanntyton.com.ar                  *
# *****************************************************

VM_FILE=~/ActiveVMs
IFS=$'\n'

while read VM; do
	echo ""
	#vboxmanage startvm $virtualmachine --type headless
	~/itops-scripts/bare-metal/vbox-on.sh "$VM"
	echo "Waiting 2 minutes for VM's services startup ..."
	sleep 120
done <$VM_FILE

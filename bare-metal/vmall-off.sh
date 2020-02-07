#!/bin/sh

# ****************************************************
# * Script to power off all running virtual machines *
# * ================================================ *
# * 2019-12-29 Gustavo Casanova                      *
# * gcasanova@hellermanntyton.com.ar                 *
# ****************************************************

source ~/itops-scripts/common/set-vm-lists.sh
IFS=$'\n'

echo ""
for VM in $(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}'); do
	if [ "$VM" != "$ESSENTIAL_NET_SERVICE" ]; then
		echo "Shutting "$VM" down ..."
		~/itops-scripts/bare-metal/vm-off.sh "$VM"
	fi
done
echo "All virtual machines stopped!"
echo ""

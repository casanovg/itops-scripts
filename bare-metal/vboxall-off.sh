#!/bin/sh

# ****************************************************
# * Script to power off all running virtual machines *
# * ================================================ *
# * 2018-03-15 Gustavo Casanova                      *
# * gcasanova@hellermanntyton.com.ar                 *
# ****************************************************

ESSENTIAL_NET_SERVICE="$(cat ~/EssentialNetServices)"
IFS=$'\n'

echo ""
for VM in $(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}'); do
	if [ "$VM" != "$ESSENTIAL_NET_SERVICE" ]; then
		~/itops-scripts/bare-metal/vbox-off.sh "$VM"
	else
		echo ""
		echo "$VM runs an essential network service, keeping it up ..."
		echo ""
	fi
done
echo ""

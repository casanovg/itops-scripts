#!/bin/sh

# *******************************************
# * Script to power internet servers VMs on *
# * ======================================= *
# * 2020-04-02 Gustavo Casanova             *
# * gcasanova@hellermanntyton.com.ar        *
# *******************************************

source ~/itops-scripts/common/set-env.sh

for INTERNET in HTA-Firewall HTA-NetPal; do
	EXIT_CODE=0
	if [ ! -z "$INTERNET" ]; then
		RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$INTERNET$")
		if [ -z "$RUNNING_VM" ]; then
			echo ""
			echo "$INTERNET virtual machine inactive, trying to power it on ..."
			vboxmanage startvm "$INTERNET" --type headless
		else
			echo ""
			echo "$INTERNET virtual machine already active!"
			EXIT_CODE=1
		fi
	else
		echo ""
		echo "$1 virtual machine not found!"
		EXIT_CODE=2
	fi
	sleep 5
done

echo ""
exit $EXIT_CODE


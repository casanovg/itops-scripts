#!/bin/sh

# ********************************************
# * Script to power internet servers VMs off *
# * ======================================== *
# * 2020-04-02 Gustavo Casanova              *
# * gcasanova@hellermanntyton.com.ar         *
# ********************************************

WAIT_TIME=300 # If the virtual machine does not stop in 5 minutes, exit
EXIT_CODE=0

for INTERNET in "HTA-NetPal" "HTA-Firewall 2"; do

	VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$INTERNET$")
	echo --- $VM
	if [ ! -z "$VM" ]; then
		RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "$VM")
		if [ ! -z "$RUNNING_VM" ]; then
			echo ""
			echo ""$RUNNING_VM" virtual machine active, sending shutdown signal ..."
			vboxmanage controlvm "$RUNNING_VM" acpipowerbutton
			sleep 2
			vboxmanage controlvm "$RUNNING_VM" acpipowerbutton
			while [[ "$RUNNING_VM" && $WAIT_TIME -gt 0 ]]; do
				RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
				((WAIT_TIME = WAIT_TIME - 1))
				#echo "$WAIT_TIME"
				sleep 1
			done
			echo ""
		else
			echo ""
			echo ""$RUNNING_VM" virtual machine not active!"
			EXIT_CODE=1
		fi
	else
		echo ""
		echo "\"$VM\" virtual machine not found!"
		EXIT_CODE=2
	fi
	sleep 1

done

echo ""
exit $EXIT_CODE


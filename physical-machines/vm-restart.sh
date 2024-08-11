#!/bin/sh

# Script to restart a single virtual machine
# ...........................................
# 2020-02-13 gustavo.casanova@gmail.com

VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
WAIT_TIME=300 # If the virtual machine does not stop in 5 minutes, exit
EXIT_CODE=0

if [ $# -eq 0 ] || [ -z "$1" ]
then
    echo ""
    echo "Usage: vm-restart.sh <VIRTUAL-MACHINE>"
else

	if [ ! -z "$VM" ]; then
		RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
		# Stop virtual machine
		if [ ! -z "$RUNNING_VM" ]; then
			echo ""
			echo ""$VM" virtual machine active, sending shutdown signal ..."
			vboxmanage controlvm "$VM" acpipowerbutton
			sleep 2
			vboxmanage controlvm "$VM" acpipowerbutton
			while [[ "$RUNNING_VM" && $WAIT_TIME -gt 0 ]]; do
				RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
				((WAIT_TIME = WAIT_TIME - 1))
				sleep 1
			done
			echo ""
		fi
		echo "$VM virtual machine stopped!"
		echo ""
		# Three-second delay
		for (( i=0; i<3; i++ ));
		do
			echo -n "."
			sleep 1
		done
		# Start virtual machine
		echo ""
		echo ""
		echo Starting "$VM virtual machine ..."
		echo ""
		vboxmanage startvm "$VM" --type headless
	else
		echo ""
		echo ""$1" virtual machine not found!"
		EXIT_CODE=2
	fi
fi
echo ""
exit $EXIT_CODE

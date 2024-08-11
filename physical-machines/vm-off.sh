#!/bin/sh

# Script to power a single virtual machine off
# .............................................
# 2018-03-15 gustavo.casanova@gmail.com

VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
WAIT_TIME=300 # If the virtual machine does not stop in 5 minutes, exit
EXIT_CODE=0

if [ ! -z "$VM" ]; then
	RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
	if [ ! -z "$RUNNING_VM" ]; then
		echo ""
		echo ""$VM" virtual machine active, sending shutdown signal ..."
		vboxmanage controlvm "$VM" acpipowerbutton
		sleep 2
		vboxmanage controlvm "$VM" acpipowerbutton
		while [[ "$RUNNING_VM" && $WAIT_TIME -gt 0 ]]; do
			RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
			((WAIT_TIME = WAIT_TIME - 1))
			#echo "$WAIT_TIME"
			sleep 1
		done
		echo ""
	else
		echo ""
		echo ""$VM" virtual machine not active!"
		echo ""
		EXIT_CODE=1
	fi
else
	#echo ""
	echo ""$1" virtual machine not found!"
	echo ""
	EXIT_CODE=2
fi
exit $EXIT_CODE

#!/bin/sh

# ************************************************
# * Script to power a single virtual machine off *
# * ============================================ *
# * 2018-03-15 Gustavo Casanova                  *
# * gcasanova@hellermanntyton.com.ar             *
# ************************************************

#VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
WAIT_TIME=300 # If the virtual machine does not stop in 5 minutes, exit
EXIT_CODE=0

for INTERNET in HTA-NetPal HTA-Firewall; do

if [ ! -z "$INTERNET" ]; then
	RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$INTERNET$")
	if [ ! -z "$RUNNING_VM" ]; then
		echo ""
		echo ""$INTERNET" virtual machine active, sending shutdown signal ..."
		vboxmanage controlvm "$INTERNET" acpipowerbutton
		sleep 2
		vboxmanage controlvm "$INTERNET" acpipowerbutton
		while [[ "$RUNNING_VM" && $WAIT_TIME -gt 0 ]]; do
			RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$INTERNET$")
			((WAIT_TIME = WAIT_TIME - 1))
			#echo "$WAIT_TIME"
			sleep 1
		done
		echo ""
	else
		echo ""
		echo ""$INTERNET" virtual machine not active!"
		echo ""
		EXIT_CODE=1
	fi
else
	#echo ""
	echo ""$1" virtual machine not found!"
	echo ""
	EXIT_CODE=2
fi

done

exit $EXIT_CODE


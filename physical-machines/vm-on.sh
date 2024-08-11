#!/bin/sh

# Script to power a single virtual machine on
# .............................................
# 2018-03-15 gustavo.casanova@gmail.com

source ~/itops-scripts/common/set-env.sh

VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
EXIT_CODE=0

if [ ! -z "$VM" ]; then
	RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
	if [ -z "$RUNNING_VM" ]; then
		echo ""
		echo "$VM virtual machine inactive, trying to power it on ..."
		vboxmanage startvm "$VM" --type headless
	else
		echo ""
		echo "$VM virtual machine already active!"
		EXIT_CODE=1
	fi
else
	echo ""
	echo "$1 virtual machine not found!"
	EXIT_CODE=2
fi
echo ""
exit $EXIT_CODE

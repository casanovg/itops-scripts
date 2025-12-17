#!/bin/sh
#!/bin/sh

# Script to power a single virtual machine on
# .............................................
# 2018-03-15 gustavo.casanova@gmail.com

source ~/itops-scripts/common/set-env.sh

VM_NAME="$1"
EXIT_CODE=0

if [ -z "$VM_NAME" ]; then
	echo "VM name not provided"
	exit 2
fi

# Resolve exact VM name
VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^${VM_NAME}$")

if [ -z "$VM" ]; then
	echo ""
	echo "${VM_NAME} virtual machine not found!"
	exit 2
fi

# Detect state to handle saved/aborted cases before start
VM_STATE=$(vboxmanage showvminfo "$VM" --machinereadable | awk -F= '/^VMState=/{gsub(/"/,"",$2);print $2}')

case "$VM_STATE" in
	running|paused|stuck)
		echo ""
		echo "$VM virtual machine already active ($VM_STATE)!"
		EXIT_CODE=1
		;;
	saved|aborted)
		echo ""
		echo "$VM virtual machine in state $VM_STATE, discarding state before start ..."
		vboxmanage discardstate "$VM" || EXIT_CODE=$?
		;;
	poweroff|*)
		:
		;;
esac

if [ $EXIT_CODE -eq 0 ] && [ "$VM_STATE" != "running" ]; then
	echo ""
	echo "$VM virtual machine inactive, trying to power it on ..."
	if ! vboxmanage startvm "$VM" --type headless; then
		EXIT_CODE=3
	fi
fi

echo ""
exit $EXIT_CODE

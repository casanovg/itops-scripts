#!/bin/sh

# Script to move a virtual machine to anothe bare-metal server
# .............................................................
# 2021-03-21 gcasanova@hellermanntyton.com.ar

VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
DEST=$2
VBOX_PATH="/data/VirtualBox-VMs"
VM_RUNNING=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep "$VM")
DO_OPT="--disk-only"

if [ $# -eq 0 ] || [ -z "$1" ] || [ -z "$2" ] || ([ ! -z "$3" ] && [ "$3" != "$DO_OPT" ])
  then
    echo ""
    echo "Usage: vm-move-out.sh <VIRTUAL-MACHINE> <DESTINATION-SERVER> ["$DO_OPT"]"
    echo ""
else
    if [ -z "$VM" ]; then
        echo ""
        echo "Virtual machine $1 not found on this server, valid options are:"
        echo ""
        vboxmanage list vms | gawk -F\" '{print $(NF-1)}'
        echo ""
    else
        ping -c1 -W1 -q $DEST &>/dev/null
        CONTACTED=$( echo $? )
        echo ""
        if [ "$CONTACTED" -ne 0 ] ; then
            echo "$DEST server can NOT be contactacted!"
        else
            echo "Remote server $DEST contacted!"
	    if [ ! -z "$VM_RUNNING" ]; then 
            	echo "$VM virtual machine is running, sending stop signal ..."	
		~/itops-scripts/bare-metal/vm-off.sh "$VM"
	    else
		echo "$VM virtual machine already stopped ..."
	    fi

	    if [ "$3" == "$DO_OPT" ]; then
		echo "Copying \"$VM\" disk/s to $DEST host ..."
		echo ""
            	rsync -r -a --relative "$VBOX_PATH"/"$VM" --include '$VBOX_PATH//$VM' --include '*.vdi *.vmdk' --exclude '*' --info=progress2 $DEST:/
	    else
		echo "Copying \"$VM\" virtual machine to $DEST host ..."
            	echo ""
            	rsync -r -a --relative "$VBOX_PATH"/"$VM" --info=progress2 $DEST:/
	    fi

	    if [ ! -z "$VM_RUNNING" ]; then
		echo "Restarting virtual machine ..."
	    fi 
        fi
        echo ""
    fi
fi


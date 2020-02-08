#!/bin/sh

# Script to clone a VirtualBox virtual machine
# .............................................
# 2020-02-07 gcasanova@hellermanntyton.com.ar

if [ $# -eq 0 ] || [ -z "$1" ]
then
    echo ""
    echo "Usage: vm-clone.sh <VIRTUAL-MACHINE> [CLONE-NAME] [--no-restart]"
    echo ""
else

    VM=$1
    if [ ! -z "$2" ] && [ "$2" != "--no-restart" ]
    then
        CLONE_NAME=$2
    else
        CLONE_NAME="$VM"-Clone-"$(date +%Y-%m-%d)"
    fi

    # Stop the virtual machine to be cloned
    echo "Stopping "
    ~/itops-scripts/bare-metal/vm-off.sh "$VM"

    # Clone virtual machine
    vboxmanage clonevm "$VM" --register --name "$CLONE_NAME"
    
    # Check if any argument contains "--no-restart"
    while test $# -gt 0
    do
        if [ ! -z "$1" ] && [ "$1" = "--no-restart" ]
        then
            RESTART_VM=0
        else
            # ~/itops-scripts/bare-metal/vm-on.sh "$VM"
            RESTART_VM=1
        fi        
        shift
    done
        if [ $RESTART_VM -eq 1 ]
        then
            # Start the virtual machine cloned
            echo ""
	    echo "Starting $VM ..."
            ~/itops-scripts/bare-metal/vm-on.sh "$VM"
        else
            echo ""
            echo "WARNING! Keeping $VM virtual machine stopped!"
        fi
        echo ""
fi

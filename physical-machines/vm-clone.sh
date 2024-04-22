#!/bin/sh

# Script to clone a VirtualBox virtual machine
# .............................................
# 2020-02-07 gustavo.casanova@gmail.com

OPT_1="--no-start"
OPT_2="--start-vm"
OPT_3="--start-clone"

if [ $# -eq 0 ] || [ -z "$1" ]
then
    echo ""
    echo "Usage: vm-clone.sh <VIRTUAL-MACHINE> [CLONE-NAME] [$OPT_1 | $OPT_2 | $OPT_3]"
    echo ""
else

    VM=$1
  
    if [ ! -z "$2" ] && [ "$2" != "$OPT_1" ] && [ "$2" != "$OPT_2" ] && [ "$2" != "$OPT_3" ]
    then
        CLONE_NAME=$2
    else
        CLONE_NAME="$VM"-Clone-"$(date +%Y-%m-%d)"
    fi

    # Stop the virtual machine to be cloned
    echo "Stopping "
    ~/itops-scripts/physical-machines/vm-off.sh "$VM"

    # Clone virtual machine
    vboxmanage clonevm "$VM" --register --name "$CLONE_NAME" # 2>/dev/null

    if [ $? -ne 0 ]
    then
        echo ""
        echo "ERROR! Unable to clone $VM virtual machine, please check whether the clone name already exists ..."
    fi
    
    # Check and execute arguments
    while test $# -gt 0
    do
        if [ ! -z "$1" ]
        then

            case "$1" in

            $OPT_1) echo ""
                    echo "WARNING! Keeping $VM and $CLONE_NAME virtual machines stopped!"
                    echo ""
                    exit 0
                    ;;

            $OPT_2) echo ""
	                echo "Starting $VM ..."
                    ~/itops-scripts/physical-machines/vm-on.sh "$VM"
                    echo ""
                    exit 0
                    ;;

            $OPT_3) echo ""
	                echo "Starting $CLONE_NAME ..."
                    ~/itops-scripts/physical-machines/vm-on.sh "$CLONE_NAME"
                    echo ""
                    exit 0
                    ;;                    

            esac

        fi        

        shift

    done

    # If there are no arguments, restart the virtual machine
    echo "Starting $VM ..."
    ~/itops-scripts/physical-machines/vm-on.sh "$VM"
    echo ""

fi

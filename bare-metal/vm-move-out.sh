#!/bin/sh

# ****************************************************************
# * Script to move a virtual machine to anothe bare-metal server *
# * ============================================================ *
# * 2020-01-16 gcasanova@hellermanntyton.com.ar                  *
# ****************************************************************

VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")
DEST=$2
VBOX_PATH="/data/VirtualBox-VMs"

if [ $# -eq 0 ] || [ -z "$1" ] || [ -z "$2" ]
  then
    echo ""
    echo "Usage: vbox-move.sh <VIRTUAL-MACHINE> <DESTINATION-SERVER>"
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
            ~/itops-scripts/bare-metal/vm-off.sh "$VM"
            echo "Copying \"$VM\" virtual machine to $DEST host ..."
            echo ""
            rsync -r -a --relative "$VBOX_PATH"/"$VM" --info=progress2 $DEST:/
        fi
        echo ""
    fi
fi



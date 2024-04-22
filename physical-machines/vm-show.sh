#!/bin/sh

# Show a virtual machine console on screen
# .........................................
# 2022-04-24 gustavo.casanova@gmail.com

VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$")

if [ $# -eq 0 ] || [ -z "$1" ]
  then
    echo ""
    echo "Usage: vm-show.sh <VIRTUAL-MACHINE>"
    echo ""
else
    if [ -z "$VM" ]; then
        echo ""
        echo "Virtual machine $1 not running on this server, valid options are:"
        echo ""
        vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}'
        echo ""
    else
	VBoxManage startvm "$VM" --type separate
    fi
fi


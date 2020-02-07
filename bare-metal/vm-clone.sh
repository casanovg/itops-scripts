#!/bin/sh

# Script to clone a VirtualBox virtual machine
# .............................................
# 2020-02-07 gcasanova@hellermanntyton.com.ar

if [ $# -eq 0 ] || [ -z "$1" ] || [ -z "$2" ]
  then
    echo ""
    echo "Usage: vm-clone.sh <VIRTUAL-MACHINE> [CLONE-NAME]"
    echo ""
else


vboxmanage clonevm HTA-Cloud --register --name HTA-Cloud-OK

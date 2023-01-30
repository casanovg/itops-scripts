#!/bin/sh

# Stop VirtualBox
# ......................................
# 2018-05-25 gustavo.casanova@gmail.com

while (test `vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}'`); do
    echo .;
    ~/itops-scripts/physical-machines/vboxall-off.sh;
    sleep 30;
done

#!/bin/sh
while (test `vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}'`); do
    echo .;
    /root/vmall-off;
    sleep 30;
done

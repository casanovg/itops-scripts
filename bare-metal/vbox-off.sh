#!/bin/sh

# ************************************************
# * Script to power a single virtual machine off *
# * ============================================ *
# * 2018-03-15 Gustavo Casanova                  *
# * gcasanova@hellermanntyton.com.ar             *
# ************************************************

VM=`vboxmanage list vms | gawk '{gsub("\"","",$1);print $1}' | grep -w $1`;
TIMES=60;

if [ ! -z "$VM" ]; then
        RUNNING_VM=`vboxmanage list runningvms | gawk '{gsub("\"","",$1);print $1}' | grep -w $VM`;
        if [ ! -z "$RUNNING_VM" ]; then
	        echo "";
       		echo "$VM virtual machine active, sending shutdown signal ...";
        	vboxmanage controlvm $VM acpipowerbutton;
        	sleep 2;
        	vboxmanage controlvm $VM acpipowerbutton;
		sleep 5;
        else
                echo "";
		echo "$VM virtual machine not active, exiting ...";
        fi
else
        echo "";
        echo "$1 virtual machine not found, exiting ...";
fi


#!/bin/sh

# ***********************************************
# * Script to power a single virtual machine on *
# * =========================================== *
# * 2018-03-15 Gustavo Casanova                 *
# * gcasanova@hellermanntyton.com.ar            *
# ************************************************

VM=`vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$"`;

if [ ! -z "$VM" ]; then
        RUNNING_VM=`vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$"`;
	if [ -z "$RUNNING_VM" ]; then
        	echo "";
        	echo ""$VM" virtual machine inactive, trying to power it on ...";
    		vboxmanage startvm "$VM" --type headless;
		echo "";
	else
        	echo "";
        	echo ""$VM" virtual machine already active, exiting ...";
        	echo "";
	fi
else
	echo "";
	echo ""$1" virtual machine not found, exiting ...";
	echo "";
fi


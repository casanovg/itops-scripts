#!/bin/sh

# ************************************************
# * Script to power a single virtual machine off *
# * ============================================ *
# * 2018-03-15 Gustavo Casanova                  *
# * gcasanova@hellermanntyton.com.ar             *
# ************************************************

VM=`vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$1$"`;

if [ ! -z "$VM" ]; then
        RUNNING_VM=`vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$"`;
        if [ ! -z "$RUNNING_VM" ]; then
	        echo "";
       		echo ""$VM" virtual machine active, sending shutdown signal ...";
        	vboxmanage controlvm "$VM" acpipowerbutton;
        	sleep 2;
        	vboxmanage controlvm "$VM" acpipowerbutton;
		sleep 5;
    		while [ "$RUNNING_VM" ]
    		do
       	 		RUNNING_VM=`vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$"`;
            		sleep 1;
    		done
                echo "";
        else
                echo "";
		echo ""$VM" virtual machine not active!";
                echo "";
        fi
else
        echo "";
        echo ""$1" virtual machine not found!";
        echo "";
fi


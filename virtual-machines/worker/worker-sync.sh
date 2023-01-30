#!/bin/sh

# Script to synchronize a worker between physical servers
# ............................................................
# 2023-01-16 gustavo.casanova@gmail.com

WORKER_VM="CW-BusinessMate"
PING_TIMEOUT=2
BARE_METAL_1=10.6.17.35
BARE_METAL_2=10.6.17.30
THIS_BARE_METAL=$(sudo hostname -s | tr a-z A-Z)
THIS_BARE_METAL_IP=$(sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '192.')

echo ""

if [ "$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$WORKER_VM$")" ]; then

	~/itops-scripts/physical-machines/vm-off.sh $WORKER_VM
	for BARE_METAL in $BARE_METAL_1 $BARE_METAL_2 $BARE_METAL_3; do
	    echo -n "physical server "
	    if [ $BARE_METAL == "$THIS_BARE_METAL_IP" ]; then
	        echo "$BARE_METAL ($THIS_BARE_METAL) This is me, won't sync!"
		echo ""
	    else
	        echo -n "$BARE_METAL "
	        if ping -c 1 -w $PING_TIMEOUT $BARE_METAL &>/dev/null; then
	            echo "active, syncing ..."
		    ~/itops-scripts/physical-machines/vm-move-out.sh $WORKER_VM $BARE_METAL --disk-only
	        else
	            echo "inactive, can't sync ..."
		fi
		#echo ""
	    fi
	done
	~/itops-scripts/physical-machines/vm-on.sh $WORKER_VM
	echo "Sync complete!"
	echo ""

else

    echo "The worker is not running here, probably isn't updated, it won't sync ..."
    echo ""

fi


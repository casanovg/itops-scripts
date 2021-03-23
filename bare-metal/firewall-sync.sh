#!/bin/sh

# Script to synchronize the firewall between bare-metal servers
# ..............................................................
# 2020-03-22 gcasanova@hellermanntyton.com.ar

FIREWALL_VM="HTA-Firewall"
PING_TIMEOUT=2
BARE_METAL_1=10.6.17.30
BARE_METAL_2=10.6.17.40
BARE_METAL_3=10.6.17.50
#BARE_METALS_ACTIVE=0
THIS_BARE_METAL=$(sudo hostname -s | tr a-z A-Z)
THIS_BARE_METAL_IP=$(sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '192.')

echo ""

if [ "$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$FIREWALL_VM$")" ]; then

	~/itops-scripts/bare-metal/vm-off.sh $FIREWALL_VM

	for BARE_METAL in $BARE_METAL_1 $BARE_METAL_2 $BARE_METAL_3; do
	    echo -n "Bare-metal server "
	    if [ $BARE_METAL == "$THIS_BARE_METAL_IP" ]; then
	        echo "$BARE_METAL ($THIS_BARE_METAL) This is me, won't sync!"
		echo ""
	    else
	        echo -n "$BARE_METAL "
	        if ping -c 1 -w $PING_TIMEOUT $BARE_METAL &>/dev/null; then
	            #BARE_METALS_ACTIVE=$((BARE_METALS_ACTIVE + 1))
	            echo "active, syncing ..."
		    ~/itops-scripts/bare-metal/vm-move-out.sh $FIREWALL_VM $BARE_METAL --disk-only
	        else
	            echo "inactive, can't sync ..."
		fi
		#echo ""
	    fi
	done
	~/itops-scripts/bare-metal/vm-on.sh $FIREWALL_VM
	echo "Sync complete!"
	echo ""

else

    echo "The firewall is not running here, probably isn't updated, it won't sync ..."
    echo ""

fi


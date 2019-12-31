#!/bin/sh

# Stop all virtual machines and reboot server
# ...........................................
# 2019-12-29 gcasanova@hellermanntyton.com.ar

SCRIPTS_REP="itops-scripts"
ESSENTIAL_NET_SERVICE="$(cat ~/EssentialNetServices)"

# Stop all virtual machines
echo ""
echo "Stopping virtual machines ..."
~/$SCRIPTS_REP/bare-metal/vboxall-off.sh
# Stopping essential net services
echo "Stopping $ESSENTIAL_NET_SERVICE essential network services, Bye Bye!"
echo ""
~/$SCRIPTS_REP/bare-metal/vbox-off.sh $ESSENTIAL_NET_SERVICE
sleep 3
# Reboot
echo ""
echo "Rebooting ..."
sudo /usr/sbin/reboot
# Start all virtual machines (in case that reboot fails)
sleep 180
echo ""
echo "Starting virtual machines ..."
~/$SCRIPTS_REP/bare-metal/vboxall-on.sh

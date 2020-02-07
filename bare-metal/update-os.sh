#!/bin/sh

# Update OS and reboot
# ...........................................
# 2019-12-24 gcasanova@hellermanntyton.com.ar

source ~/itops-scripts/common/set-vm-lists.sh

# Stop all virtual machines
~/itops-scripts/bare-metal/vmall-off.sh
# Update OS
sleep 3
echo ""
echo "Looking for updates ..."
sudo dnf -y update
sleep 3
# Stopping essential net services
echo ""
echo "Stopping $ESSENTIAL_NET_SERVICE essential network services, Bye!"
~/itops-scripts/bare-metal/vm-off.sh "$ESSENTIAL_NET_SERVICE"
sleep 3
# Reboot
echo ""
echo "Rebooting ..."
sudo /usr/sbin/reboot
# Start all virtual machines (in case that reboot fails)
~/itops-scripts/bare-metal/vmall-on.sh

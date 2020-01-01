#!/bin/sh

# Update OS and reboot
# ...........................................
# 2019-12-24 gcasanova@hellermanntyton.com.ar

ESSENTIAL_NET_SERVICE="$(cat ~/EssentialNetServices)"

# Stop all virtual machines
~/itops-scripts/bare-metal/vboxall-off.sh
# Update OS
sleep 3
echo ""
echo "Looking for updates ..."
sudo dnf -y update
sleep 3
# Stopping essential net services
echo ""
echo "Stopping $ESSENTIAL_NET_SERVICE essential network services, Bye!"
~/itops-scripts/bare-metal/vbox-off.sh "$ESSENTIAL_NET_SERVICE"
sleep 3
# Reboot
echo ""
echo "Rebooting ..."
sudo /usr/sbin/reboot
# Start all virtual machines (in case that reboot fails)
~/itops-scripts/bare-metal/vboxall-on.sh

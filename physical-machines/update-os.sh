#!/bin/sh

# Update OS and reboot
# ......................................
# 2019-12-24 gustavo.casanova@gmail.com

source ~/itops-scripts/common/set-vm-lists.sh

# Stop all virtual machines
if command -v vboxmanage &> /dev/null; then
	if [ ! -n "$(vboxmanage --version | grep "WARNING")" ]; then
		~/itops-scripts/physical-machines/vboxall-off.sh
	fi
fi

# Update OS
sleep 3
echo ""
echo "Looking for updates ..."
sudo dnf -y update
sleep 3

# Stopping essential net services
if command -v vboxmanage &> /dev/null; then
	if [ ! -n "$(vboxmanage --version | grep "WARNING")" ]; then
		echo ""
		echo "Stopping $ESSENTIAL_NET_SERVICE essential network services, Bye!"
		~/itops-scripts/physical-machines/vm-off.sh "$ESSENTIAL_NET_SERVICE"
		sleep 3
	fi
fi

# Reboot
echo ""
echo "Rebooting ..."
sudo shutdown -r now

# Start all virtual machines (in case that reboot fails)
if command -v vboxmanage &> /dev/null; then
	if [ ! -n "$(vboxmanage --version | grep "WARNING")" ]; then
		~/itops-scripts/physical-machines/vboxall-on.sh
	fi
fi


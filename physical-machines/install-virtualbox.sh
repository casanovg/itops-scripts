#!/bin/sh

# Install VirtualBox on a physical server
# ............................................
# 2020-01-16 gustavo.casanova@gmail.com

NEW_VBOX_LINK="https://download.virtualbox.org/virtualbox/6.1.2/VirtualBox-6.1-6.1.2_135662_fedora31-1.x86_64.rpm"
NEW_VBOX="VirtualBox-6.1"
OLD_VBOX="VirtualBox-6.0"
DELAY=10

# ~/itops-scripts/physical-machines/vboxall-off.sh
echo "Getting VirtualBox repo ..."
sudo wget $NEW_VBOX_LINK
echo "Importing VirtualBox repo ..."
sudo sudo rpm --import oracle_vbox.asc
echo "Stopping all VirtualBox processes ..."
sudo kill $(ps -C virtualbox -o pid | grep -v PID)
sudo kill $(ps -C VirtualBox -o pid | grep -v PID)
sudo kill $(ps -C VBox -o pid | grep -v PID)
echo "Waiting "$DELAY" seconds ..."
sleep $DELAY
echo "Removing old VirtualBox version ..."
sudo dnf remove -y $OLD_VBOX
echo "Installing new VirtualBox version ..."
sudo dnf install -y $NEW_VBOX
echo "Removing installation files ..."
sudo rm -f VirtualBox*.rpm
# ~/itops-scripts/physical-machines/vboxall-on.sh

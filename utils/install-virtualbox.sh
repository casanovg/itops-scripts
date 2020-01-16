#!/bin/sh

# Install VirtualBox
# ...........................................
# 2020-01-16 gcasanova@hellermanntyton.com.ar

NEW_VBOX_LINK="https://download.virtualbox.org/virtualbox/6.1.2/VirtualBox-6.1-6.1.2_135662_fedora31-1.x86_64.rpm"
NEW_VBOX="VirtualBox-6.1"
OLD_VBOX="VirtualBox-6.0"

sudo wget $NEW_VBOX_LINK 
sudo sudo rpm --import oracle_vbox.asc
sudo dnf remove -y $OLD_VBOX
sudo dnf install -y $NEW_VBOX
sudo rm -f *.rpm


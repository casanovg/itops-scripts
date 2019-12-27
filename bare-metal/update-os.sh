#!/bin/sh

# Update OS and reboot
# ...........................................
# 2019-12-24 gcasanova@hellermanntyton.com.ar

# Stop all virtual machines
/home/netbackup/itops-scripts/bare-metal/vboxall-off.sh;
# Update OS
sleep 5;
sudo dnf -y update;
# Reboot
sudo /usr/sbin/reboot;
# Start all virtual machines (in case that reboot fails)
/home/netbackup/itops-scripts/bare-metal/vboxall-on.sh;


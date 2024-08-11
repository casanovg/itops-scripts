#!/bin/sh

# Update OS and reboot
# ......................................
# 2020-01-03 gustavo.casanova@gmail.com

echo "Looking for updates ..."
sudo dnf -y update
sleep 3
# Reboot
echo ""
echo "Rebooting ..."
sudo shutdown -r now
echo ""


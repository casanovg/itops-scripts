#!/bin/sh

# Install X11 basic
# .......................................
# 2020-01-31  gustavo.casanova@gmail.com

# X11 minimal  installation
sudo dnf install -y xorg-x11-server-Xorg xorg-x11-xauth # xorg-x11-apps

# x11 test apps
sudo dnf install -y xeyes xclock

# Restart ssh daemon
sudo systemctl restart sshd

# X11 forwarding reminder
echo ""
echo "==================================================================="
echo "= Please verify that X11 forwarding is enabled in sshd_config ... ="
echo "= $ sudo vim /etc/ssh/sshd_config                                 ="
echo "= X11Forwarding yes                                               ="
echo "==================================================================="
echo ""

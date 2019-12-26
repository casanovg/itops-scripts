#!/bin/sh

# Update OS and reboot
# ...........................................
# 2019-12-24 gcasanova@hellermanntyton.com.ar

# Stop all virtual machines
/root/vboxall-off.sh;
# Update OS
sleep 5;
dnf -y update;
# Reboot
/usr/sbin/reboot;


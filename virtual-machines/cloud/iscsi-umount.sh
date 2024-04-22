#!/bin/sh

# HTA cloud iscsi disks mount
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

# Unmount HTA Seafile cloud iscsi disk
sudo umount /data/seafile-data;
# Unmount HTA Mattermost iscsi disk
sudo umount /data/mattermost-data;
echo;
# Disconnect HTA Seafile cloud iscsi target
sudo iscsiadm -m node --targetname iqn.2020-01.lan.htargentina:hta-mothership.cloud -p 10.6.17.40 --logout;
# Disconnect HTA Mattermost iscsi target
sudo iscsiadm -m node --targetname iqn.2020-03.lan.htargentina:hta-mothership.mattermost -p 10.6.17.40 --logout;
echo;
cat /proc/partitions;
echo;

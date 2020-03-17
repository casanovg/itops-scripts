#!/bin/sh

# HTA cloud iscsi disks mount
# ............................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

# Unmount HTA cloud iscsi disk
sudo umount /data/seafile-data;
# Unmount Mattermost iscsi disk
sudo umount /data/mattermost-disk;
echo;
# Disconnect HTA files and users shares iscsi target
sudo iscsiadm -m node --targetname iqn.2020-01.lan.htargentina:hta-mothership.cloud -p 10.6.17.40 --logout;
# Disconnect finance tax payers records iscsi target
sudo iscsiadm -m node --targetname iqn.2020-03.lan.htargentina:hta-mothership.mattermost -p 10.6.17.40 --logout;
echo;
cat /proc/partitions;
echo;

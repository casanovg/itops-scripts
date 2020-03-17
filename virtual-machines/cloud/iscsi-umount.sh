#!/bin/sh

# HTA cloud iscsi disks mount
# ............................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

# Unmount HTA cloud iscsi disk
umount /dev/sdb1 /data/seafile-data;
# Unmount Mattermost iscsi disk
umount /dev/sdc1 /data/mattermost-disk;
echo;
# Disconnect HTA files and users shares iscsi target
iscsiadm -m node --targetname iqn.2019-12.lan.htargentina:hta-mothership.aleph -p 10.6.17.40 --logout;
# Disconnect finance tax payers records iscsi target
iscsiadm -m node --targetname iqn.2019-12.lan.htargentina:hta-mothership.taxpy -p 10.6.17.40 --logout;
echo;
cat /proc/partitions;
echo;

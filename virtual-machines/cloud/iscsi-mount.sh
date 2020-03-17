#!/bin/sh

# HTA cloud iscsi disks mount
# ............................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

# Connect HTA cloud iscsi target
iscsiadm -m node --targetname iqn.2020-01.lan.htargentina:hta-mothership.cloud -p 10.6.17.40 --login;
# Connect Mattermost iscsi target
iscsiadm -m node --targetname iqn.2020-03.lan.htargentina:hta-mothership.mattermost -p 10.6.17.40 --login;

sleep 5;
cat /proc/partitions;
echo;

# Mount HTA cloud iscsi disk
mount /dev/sdb1 /data/seafile-data;
# Mount Mattermost iscsi disk
mount /dev/sdc1 /data/mattermost-data;

ls -l /data/seafile-data;
echo;
ls -l /data/mattermost-data;
echo;

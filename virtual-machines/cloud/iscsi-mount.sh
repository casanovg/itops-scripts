#!/bin/sh

# HTA cloud iscsi disks mount
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

echo ""
sudo iscsiadm -m discovery -t sendtargets -p 10.6.17.40

# Connect HTA Seafile cloud iscsi target
sudo iscsiadm -m node --targetname iqn.2020-01.lan.htargentina:hta-mothership.cloud -p 10.6.17.40 --login;
# Connect Mattermost iscsi target
sudo iscsiadm -m node --targetname iqn.2020-03.lan.htargentina:hta-mothership.mattermost -p 10.6.17.40 --login;

sleep 5;
sudo cat /proc/partitions;
echo;

# Mount HTA Seafile cloud iscsi disk
sudo mount /dev/disk/by-uuid/7736fa41-9671-4cfe-88ca-5dd13497eaee /data/seafile-data;
# Mount Mattermost iscsi disk
sudo mount /dev/disk/by-uuid/e096e751-9598-40ac-83a8-833faddea058 /data/mattermost-data;

ls -l /data/seafile-data;
echo;
ls -l /data/mattermost-data;
echo;

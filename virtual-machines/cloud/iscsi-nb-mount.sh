#!/bin/sh

# Hibou cloud iscsi disks mount
# ......................................
# 2020-03-22 gustavo.casanova@gmail.com

echo ""
sudo iscsiadm -m discovery -t sendtargets -p 10.6.17.70

# Connect Hibou cloud iscsi target
sudo iscsiadm -m node --targetname iqn.2020-02.lan.htargentina:hta-freenas:hibou -p 10.6.17.70 --login;

sleep 5;
sudo cat /proc/partitions;
echo;

# Mount Hibou cloud iscsi disk
sudo mount /dev/disk/by-uuid/790a7298-3169-44c6-b568-7e37d4d80b55 /data/seafile-data;

ls -l /data/seafile-data;
echo;


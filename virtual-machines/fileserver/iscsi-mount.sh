#!/bin/sh

# HTA iscsi disks mount
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

# Connect HTA files and users shares iscsi target
iscsiadm -m node --targetname iqn.2019-12.lan.htargentina:hta-mothership.aleph -p 10.6.17.40 --login;
# Connect finance tax payers records iscsi target
iscsiadm -m node --targetname iqn.2019-12.lan.htargentina:hta-mothership.taxpy -p 10.6.17.40 --login;

sleep 5;
cat /proc/partitions;
echo;

# Mount HTA files and users shares iscsi disk
mount /dev/sdb1 /data/aleph-disk;
# Mount finance tax payers records iscsi disk
mount /dev/sdc1 /data/taxpy-disk;

ls -l /data/aleph-disk;
echo;
ls -l /data/taxpy-disk;
echo;

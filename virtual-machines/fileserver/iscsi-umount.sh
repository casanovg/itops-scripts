#!/bin/sh

# HTA iscsi disks mount
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

# Unmount HTA files and users shares iscsi disk
umount /dev/sdb1 /data/aleph-disk;
# Unmount finance tax payers records iscsi disk
umount /dev/sdc1 /data/taxpy-disk;
echo;
# Disconnect HTA files and users shares iscsi target
iscsiadm -m node --targetname iqn.2019-12.lan.htargentina:hta-mothership.aleph -p 10.6.17.40 --logout;
# Disconnect finance tax payers records iscsi target
iscsiadm -m node --targetname iqn.2019-12.lan.htargentina:hta-mothership.taxpy -p 10.6.17.40 --logout;
echo;
cat /proc/partitions;
echo;

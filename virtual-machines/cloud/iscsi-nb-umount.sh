#!/bin/sh

# Hibou cloud iscsi disks mount
# ......................................
# 2019-03-22 gustavo.casanova@gmail.com

# Unmount Hibou cloud iscsi disk
sudo umount /data/seafile-data;
echo;
# Disconnect Hibou cloud iscsi target
sudo iscsiadm -m node --targetname iqn.2020-02.lan.htargentina:hta-freenas:hibou -p 10.6.17.70 --logout;
echo;
cat /proc/partitions;
echo;

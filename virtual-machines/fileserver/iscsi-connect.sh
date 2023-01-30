#!/bin/sh

# HTA iscsi disks connect
# ......................................
# 2019-12-30 gustavo.casanova@gmail.com

TARGET_ALEPH="iqn.2019-12.lan.htargentina:hta-mothership.aleph"
TARGET_TAXPY="iqn.2019-12.lan.htargentina:hta-mothership.taxpy"
SERVER_ALEPH="10.6.17.40"
SERVER_TAXPY="10.6.17.40"

echo ""
# Connect HTA files and users shares iscsi target
sudo iscsiadm -m node --targetname $TARGET_ALEPH -p $SERVER_ALEPH --login
# Connect finance tax payers records iscsi target
sudo iscsiadm -m node --targetname $TARGET_TAXPY -p $SERVER_TAXPY --login

echo ""
cat /proc/partitions
echo ""

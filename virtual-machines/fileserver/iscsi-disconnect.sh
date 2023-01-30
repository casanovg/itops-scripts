#!/bin/sh

# HTA iscsi disks disconnect
# ......................................
# 2019-12-30 gustavo.casanova@gmail.com

TARGET_ALEPH="iqn.2019-12.lan.htargentina:hta-mothership.aleph"
TARGET_TAXPY="iqn.2019-12.lan.htargentina:hta-mothership.taxpy"
SERVER_ALEPH="10.6.17.40"
SERVER_TAXPY="10.6.17.40"

echo ""
# Disconnect HTA files and users shares iscsi target
sudo iscsiadm -m node --targetname $TARGET_ALEPH -p $SERVER_ALEPH --logout
# Disconnect finance tax payers records iscsi target
sudo iscsiadm -m node --targetname $TARGET_TAXPY -p $SERVER_TAXPY --logout

echo ""
cat /proc/partitions
echo ""

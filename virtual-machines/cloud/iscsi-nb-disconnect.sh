#!/bin/sh

# Hibou iscsi disks disconnect
# ............................................
# 2020-03-22 gustavo.casanova@gmail.com

TARGET_CLOUD="iqn.2020-02.lan.htargentina:hta-freenas:hibou"
SERVER_CLOUD="10.6.17.70"

echo ""
# Disconnect Hibou Seafile cloud iscsi target
sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --logout

echo ""
cat /proc/partitions
echo ""

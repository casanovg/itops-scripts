#!/bin/sh

# Hibou iscsi disks connect
# ............................................
# 2019-03-22 gcasanova@hellermanntyton.com.ar

TARGET_CLOUD="iqn.2020-02.lan.htargentina:hta-freenas:hibou"
SERVER_CLOUD="10.6.17.70"

echo ""
sudo iscsiadm -m discovery -t sendtargets -p $SERVER_CLOUD

echo ""
# Connect NB Hibou Seafile cloud iscsi target
sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --login

sleep 2

echo ""
sudo cat /proc/partitions
echo ""


#!/bin/sh

# HTA iscsi disks connect
# ......................................
# 2019-12-30 gustavo.casanova@gmail.com

TARGET_CLOUD="iqn.2020-01.lan.htargentina:hta-mothership.cloud"
TARGET_MATTERMOST="iqn.2020-03.lan.htargentina:hta-mothership.mattermost"
SERVER_CLOUD="10.6.17.40"
SERVER_MATTERMOST="10.6.17.40"

echo ""
sudo scsiadm -m discovery -t sendtargets -p $SERVER_CLOUD

echo ""
# Connect HTA Seafile cloud iscsi target
sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --login

sleep 2

# Connect HTA Mattermost iscsi target
sudo iscsiadm -m node --targetname $TARGET_MATTERMOST -p $SERVER_MATTERMOST --login

sleep 2

echo ""
sudo cat /proc/partitions
echo ""

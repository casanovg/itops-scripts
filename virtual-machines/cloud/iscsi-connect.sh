#!/bin/sh

# HTA iscsi disks connect
# ............................................
# 2019-12-30 gcasanova@hellermanntyton.com.ar

TARGET_CLOUD="iqn.2020-01.lan.htargentina:hta-mothership.cloud"
TARGET_MATTERMOST="iqn.2020-03.lan.htargentina:hta-mothership.mattermost"
SERVER_CLOUD="10.6.17.40"
SERVER_MATTERMOST="10.6.17.40"

echo ""
# Connect Seafile cloud iscsi target
sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --login
# Connect Mattermost iscsi target
sudo iscsiadm -m node --targetname $TARGET_MATTERMOST -p $SERVER_MATTERMOST --login

echo ""
cat /proc/partitions
echo ""

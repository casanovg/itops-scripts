#!/bin/sh

# HTA iscsi disks disconnect
# ......................................
# 2019-12-30 gustavo.casanova@gmail.com

TARGET_CLOUD="iqn.2020-01.lan.htargentina:hta-mothership.cloud"
TARGET_MATTERMOST="iqn.2020-03.lan.htargentina:hta-mothership.mattermost"
SERVER_CLOUD="10.6.17.40"
SERVER_MATTERMOST="10.6.17.40"

echo ""
# Disconnect HTA Seafile cloud iscsi target
sudo iscsiadm -m node --targetname $TARGET_CLOUD -p $SERVER_CLOUD --logout
# Disconnect HTA Mattermost iscsi target
sudo iscsiadm -m node --targetname $TARGET_MATTERMOST -p $SERVER_MATTERMOST --logout

echo ""
cat /proc/partitions
echo ""

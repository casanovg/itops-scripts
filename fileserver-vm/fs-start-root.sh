#!/bin/sh

# HTA filesystem start
# ...........................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

pwd=$(cat /root/fs-usr | openssl aes-256-cbc -a -d -salt -pass pass:' ')
echo ""
echo "Joining HTARGENTINA Domain"
echo "--------------------------"
echo "Windows domain administrator password required ..."
net ads join -U administrator%$pwd -S hta-pdc.htargentina.lan -I 10.6.17.45
winbindd
smbd
nmbd
wbinfo --ping-dc
getent group "HTARGENTINA\\Domain Users"
# chown "HTARGENTINA\domain admins:HTARGENTINA\domain users" /data/aleph-disk/
net rpc rights grant "HTARGENTINA\Domain Admins" SeDiskOperatorPrivilege -U "HTARGENTINA\administrator%$pwd"
net rpc rights list privileges SeDiskOperatorPrivilege -U "HTARGENTINA\administrator%$pwd"

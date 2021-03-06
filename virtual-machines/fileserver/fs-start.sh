#!/bin/sh

# HTA filesystem start
# ...........................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

pwd=$(sudo cat ~/.fs-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')

echo""
echo "Joining HTARGENTINA Domain"
echo "--------------------------"
echo "Using \"fs-usr\" domain administrator password ..."
sudo net ads join -U administrator%$pwd -S hta-adp.hellermanntyton.ar -I 10.6.17.41
sudo winbindd
sudo smbd
sudo nmbd
sudo wbinfo --ping-dc
sudo getent group "HTAR\\Domain Users"
# chown "HTARGENTINA\domain admins:HTARGENTINA\domain users" /data/aleph-disk/
sudo net rpc rights grant "HTAR\Domain Admins" SeDiskOperatorPrivilege -U "HTAR\administrator%$pwd"
sudo net rpc rights list privileges SeDiskOperatorPrivilege -U "HTAR\administrator%$pwd"
echo ""

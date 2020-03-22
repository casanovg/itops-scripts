#!/bin/sh

# HTA filesystem start
# ...........................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

pwd=$(sudo cat ~/.fs-usr | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')
echo "Joining HTARGENTINA Domain"
echo "--------------------------"
echo "Windows domain administrator password required ..."
sudo net ads join -U administrator%$pwd -S hta-pdc.htargentina.lan -I 10.6.17.45
sudo winbindd
sudo smbd
sudo nmbd
sudo wbinfo --ping-dc
sudo getent group "HTARGENTINA\\Domain Users"
# chown "HTARGENTINA\domain admins:HTARGENTINA\domain users" /data/aleph-disk/
sudo net rpc rights grant "HTARGENTINA\Domain Admins" SeDiskOperatorPrivilege -U "HTARGENTINA\administrator%$pwd"
sudo net rpc rights list privileges SeDiskOperatorPrivilege -U "HTARGENTINA\administrator%$pwd"


#!/bin/sh

# HTA filesystem start
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

pwd=$(sudo cat ~/.fs-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')

DC_FQDN="hta-adp.hellermanntyton.ar"
DC_ADDR="10.6.17.41"
ADM_USR="HTAR\administrator"
ADM_GRP="HTAR\Domain Admins"
USR_GRP="HTAR\Domain Users"

echo""
echo "Joining HellermannTyton.ar Domain"
echo "---------------------------------"
echo "Using \"fs-usr\" domain administrator password ..."
sudo net ads join -U administrator%"$pwd" -S $DC_FQDN -I $DC_ADDR 
sudo winbindd
sudo smbd
sudo nmbd
sudo wbinfo --ping-dc
sudo getent group $USR_GRP
# chown "HTAR\domain admins:HTAR\domain users" /data/netfiles-disk/
sudo net rpc rights grant $ADM_GRP SeDiskOperatorPrivilege -U $ADM_USR%$pwd -I $DC_ADDR
sudo net rpc rights list privileges SeDiskOperatorPrivilege -U $ADM_USR%$pwd -I $DC_ADDR
echo ""

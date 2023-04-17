#!/bin/sh

# HTA filesystem start
# .......................................
# 2019-12-09 gustavo.casanova@gmail.com

ADM_USR="$(cat ~/.fs-usr | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')"
ADM_PWD="$(cat ~/.fs-pwd | openssl aes-256-cbc -d -pbkdf2 -pass pass:' ')"

DM_SHNM="HTAR"
DM_FQDN="hellermanntyton.ar"
DC_NAME="HTA-ADP"
DC_ADDR="10.6.17.41"

DC_FQDN="$DC_NAME.$DM_FQDN"
ADM_ACC="$DM_SHNM\\$ADM_USR"
ADM_GRP="$DM_SHNM\\Domain Admins"
USR_GRP="$DM_SHNM\\Domain Users"

echo""
echo "Joining HellermannTyton.ar Domain"
echo "---------------------------------"
echo "Using \"$ADM_USR\" domain administrator password ..."
sudo net ads join -U "$ADM_USR"%"$ADM_PWD" -S $DC_FQDN -I $DC_ADDR
sudo winbindd
sudo smbd
sudo nmbd
sudo wbinfo --ping-dc
sudo getent group $USR_GRP
# sudo "$ADM_GRP:$USR_GRP" /data/netfiles-disk/ 
# sudo net rpc rights grant $ADM_GRP SeDiskOperatorPrivilege -U $ADM_USR%$pwd -I $DC_ADDR
# sudo net rpc rights list privileges SeDiskOperatorPrivilege -U $ADM_USR%$pwd -I $DC_ADDR
echo ""


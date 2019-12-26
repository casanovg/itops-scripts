#!/bin/sh

# HTA filesystem update password
# ...........................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

echo ""
echo "················································"
echo "· Please enter the domain admin's new password ·"
echo "················································"
stty_orig=`stty -g`
stty -echo
read pwd 1>/dev/null
stty $stty_orig
echo "$pwd" | openssl aes-256-cbc -a -salt -pass pass:' ' > /root/fs-usr
echo ""
echo "#############################################################################"
echo "# ATTENTION! The new administrator's password is:" $pwd
echo "#############################################################################"
echo ""

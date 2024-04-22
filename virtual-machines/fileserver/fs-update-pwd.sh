#!/bin/bash

# HTA filesystem update password
# ......................................
# 2020-10-13 gustavo.casanova@gmail.com

clear

echo ""
echo "··········································"
echo "· Please enter the domain admin username ·"
echo "··········································"
echo -n " > "
read -r USR
echo "$USR" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.fs-usr

echo ""
echo "··········································"
echo "· Please enter the domain admin password ·"
echo "··········································"
stty_orig=$(stty -g)
stty -echo
echo -n " > "
read -r -s PWD
stty $stty_orig
echo "$PWD" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.fs-pwd
echo ""

stty sane

clear

echo ""
echo "#############################################################################"
echo "# ATTENTION!"
echo -n "# Domain admin username set to: [ $USR ] password: [ "

LPWD="${#PWD}"
SHOW="$(( LPWD * 1 / 3 ))"

for (( i=0; i<"$LPWD"; i++ )); do
        if [ $i -lt "$((LPWD-$SHOW))" ]; then
                echo -n "*";
        else
                echo -n "${PWD:$i:1}";
        fi
done;
echo " ]"

echo "#############################################################################"
echo ""

stty sane
sleep 3
clear

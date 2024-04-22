#!/bin/bash

# Update Windows domain user for mounting shares ID
# ..................................................
# 2023-01-22 gustavo.casanova@gmail.com

clear

echo ""
echo "····························································"
echo "· Please enter the Windows domain username to mount shares ·"
echo "····························································"
echo -n " > "
read -r USR
echo "$USR" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.windowsshares-usr

echo ""
echo "··································"
echo "· Please enter the user password ·"
echo "··································"
stty_orig=$(stty -g)
stty -echo
echo -n " > "
read -r -s PWD
stty $stty_orig
echo "$PWD" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.windowsshares-pwd
echo ""

stty sane

clear

echo ""
echo "#############################################################################"
echo "# ATTENTION!"
echo -n "# Windows shares username set to: [ $USR ] password: [ "

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

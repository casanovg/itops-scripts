#!/bin/bash

# Update GitHub user and password ***
# ...........................................
# 2020-01-03 gcasanova@hellermanntyton.com.ar

clear

echo ""
echo "·····································"
echo "· Please enter your GitHub username ·"
echo "·····································"
echo -n " > "
read USR
echo "$USR" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.github-usr

echo ""
echo "·····································"
echo "· Please enter your GitHub password ·"
echo "·····································"
stty_orig=$(stty -g)
stty -echo
echo -n " > "
read PWD 1>/dev/null
stty $stty_orig
echo "$PWD" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.github-pwd
echo ""

stty sane

GIT_USER_NAME="$(git config --list | grep 'user.name')"
GIT_USER_EMAIL="$(git config --list | grep 'user.email')"

if [ -z "$GIT_USER_NAME" ]; then
        echo "·······························"
        echo "· Please enter your full name ·"
        echo "·······························"
        read FULLNAME
        git config --global user.name "$FULLNAME"
fi

if [ -z "$GIT_USER_EMAIL" ]; then
        echo "····························"
        echo "· Please enter your e-mail ·"
        echo "····························"
        read EMAIL
        git config --global user.email "$EMAIL"
fi

clear

echo ""
echo "#######################################################################"
echo "# ATTENTION!"
echo -n "# GitHub username set to: [ $USR ] password: [ "

LPWD=${#PWD}
SHOW=$(( LPWD * 1 / 3 ))

for (( i=0; i<$LPWD; i++ )); do
        if [ $i -lt $((LPWD-$SHOW)) ]; then
                echo -n "*";
        else
                echo -n "${PWD:$i:1}";
        fi
done;
echo " ]"

echo "#######################################################################"
echo "# Git user : $(echo "${GIT_USER_NAME#*"="}")"
echo "# Git eMail: $(echo "${GIT_USER_EMAIL#*"="}")"
echo "#######################################################################"
echo ""

stty sane
sleep 3
clear


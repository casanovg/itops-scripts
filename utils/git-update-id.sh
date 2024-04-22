#!/bin/bash

# Update GitHub account user and password
# ........................................
# 2020-10-13 gustavo.casanova@gmail.com

clear

if [ ! -z $1 ]; then
    if [ "$1" == "--unset" ] || [ "$1" == "-u" ]; then
    LOOP_CLEAR=1
    while [ $LOOP_CLEAR -eq 1 ]; do
	echo
        read -p "Do you wish to clear current settings? " yn
        case $yn in
            [Yy]* ) LOOP_CLEAR=0;;
            [Nn]* ) echo
		    exit
		    ;;
            * ) echo "Please answer yes or no."
	    	echo
	    	;;
        esac
        done 
        echo
    	echo "Clearing GitHub account settings ..."
	echo
	rm -f ~/.github-usr
	rm -f ~/.github-pwd
        git config --global --unset user.name
        git config --global --unset user.email
        exit 0
    else
        echo
	echo "git-update-id.sh: valid options are ..."
	echo
	echo "   $ git-update-id.sh            : No arguments = set GitHub account"
	echo "   $ git-update-id.sh --unset    : Clear GitHub account settings" 
	echo "   $ git-update-id.sh -u         : Same as --unset"
        echo
	exit 1
    fi

fi

GIT_USER_NAME="$(git config --list | grep 'user.name')"
GIT_USER_EMAIL="$(git config --list | grep 'user.email')"

if [ -f ~/.github-usr ] && [ -f ~/.github-pwd ] && [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then
    echo
    echo "WARNING: GitHub account settings found!"
    echo
    LOOP_OVRW=1
    while [ $LOOP_OVRW -eq 1 ]; do
        read -p "Do you wish to overwrite current settings? " yn
        case $yn in
            [Yy]* ) LOOP_OVRW=0;;
            [Nn]* ) echo
		    exit
		    ;;
            * ) echo "Please answer yes or no."
		echo
		;;
	      
        esac
    done
fi

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


if [ -z "$GIT_USER_NAME" ]; then
        echo "·······························"
        echo "· Please enter your full name ·"
        echo "·······························"
        echo -n " > "
        read FULLNAME
        git config --global user.name "$FULLNAME"
        GIT_USER_NAME="$(git config --list | grep 'user.name')"
fi

if [ -z "$GIT_USER_EMAIL" ]; then
        echo "····························"
        echo "· Please enter your e-mail ·"
        echo "····························"
        echo -n " > "
        read EMAIL
        git config --global user.email "$EMAIL"
        GIT_USER_EMAIL="$(git config --list | grep 'user.email')"
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


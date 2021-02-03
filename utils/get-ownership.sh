#!/bin/bash

# Script to get permissions and ownership of files and
# directories. Its output is ready to be included in a
# shell script for re-applying them.
# ....................................................
# 2021-02-03 gcasanova@hellermanntyton.com.ar


OPT_1="--with-permissions"
OPT_2="--show-errors"

if [ $# -eq 0 ] || [ -z "$1" ] || [ "$1" == "$OPT_1" ]
then
    echo ""
    echo "Usage: get-ownership.sh <PATH> [$OPT_1]"
    echo ""
else

    if [ $# -ge 2 ] && [ "$2" != "$OPT_1" ]
    then
	echo
        echo " $2: option not found"
	echo
	exit 1
    fi  

    if [ $# -ge 3 ] && [ "$3" != "$OPT_2" ]
    then
	echo
        echo " $2: option not found"
	echo
	exit 1
    fi  

    if [ -d $1 ]
    then
        echo ""
        for path in $(find $1); do
            echo -n "if [ -d $path ] || [ -f $path ]; then sudo chown $(stat -c %U:%G $path) $path; "
            if [ "$2" == "$OPT_1" ]
	    then
                echo "sudo chmod $(stat -c %a $path) $path;"
            fi  
            echo "fi"    
        done
	echo ""
    else
        echo ""
        echo "$1: path not found"
        echo ""
    fi

fi


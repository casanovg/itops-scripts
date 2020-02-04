#!/bin/bash
if [ -z $1 ]
then
	echo ""
	echo "Usage: set-mysql-root-pwd.sh <YOUR_MYSQL_ROOT_PASSWORD>"
	echo ""
else
	echo ""
	echo "$1" | openssl aes-256-cbc -pbkdf2 -pass pass:' ' > ~/.mysql-root-pwd
	echo "MySQL password set!"
	echo ""
fi

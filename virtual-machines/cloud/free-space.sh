#!/bin/bash

# Clean logs to free disk space
# ......................................
# 2022-06-22 gustavo.casanova@gmail.com

if [ "$EUID" -ne 0 ]
	then
		echo ""
		echo "........................................"
		echo ". Please run this script as superuser! ."
		echo ". e.g. \"sudo ./free-space.sh\"          ."
		echo "........................................"
		echo ""
  	exit
fi

# sudo du /var/log/* -hsx * | sort -rh | head -20

init 3

for DIR in "/var/log/sssd" "/var/log/nginx"; do
	for FILE in $(ls -1 $DIR); do
		echo "---> " $FILE
		echo "" > $DIR/$FILE
	done
done

sudo rm -rf /var/log/journal/*
sudo echo "" > /var/log/messages

echo ""
echo "File cleanup finished, please reboot the machine!"
echo ""

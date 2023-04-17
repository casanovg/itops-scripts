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
echo
echo "............................................"
echo ". Switching to runlevel 3, please wait ... ."
echo "............................................"
echo

init 3

echo "Cleaning log files ..."
echo

for DIR in "/var/log/sssd" "/var/log/nginx"; do
	for FILE in $(ls -1 $DIR); do
		echo "---> " $FILE
		echo "" > $DIR/$FILE
	done
done

sudo rm -rf /var/log/journal/*
sudo echo "" > /var/log/messages

echo ""
echo "File cleanup finished, rebooting the machine ..."
echo

SECS=9

while [ "$SECS" -gt 0 ]; do
	echo -n -e "\r >>>  $SECS     ";
	SECS="$(($SECS-1))";
	sleep 1;
done
echo -n -e "\r >>>  BYE!  ";
sleep 2
echo
echo

sudo shutdown -r now


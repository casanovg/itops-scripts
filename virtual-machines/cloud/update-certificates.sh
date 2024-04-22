#!/bin/sh

# Script to update Let's Encrypt certificates
# ............................................
# 2023-05-25 gustavo.casanova@gmail.com

clear

echo
echo "************************************************************************"
echo "*                                                                      *"
echo "* Make sure that your internet firewall allows http (port 80) to pass! *"
echo "*                                                                      *"
echo "************************************************************************"
echo

sleep 3

sudo firewall-cmd --add-service=http
sudo certbot renew
sudo firewall-cmd --remove-service=http


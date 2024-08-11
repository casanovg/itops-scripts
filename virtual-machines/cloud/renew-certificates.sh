!#/bin/bash

# Renew Let's encrypt certificates
# 2023-11-01 gcasanova@hellermanntyton.com.ar

clear
echo
echo "................................................................."
echo ".                                                               ."
echo ". The certificate renewal needs to have port 80 enabled in this ."
echo ". machine's internal firewall and in the internet firewall.     ."
echo ".                                                               ."
echo ". This script enables the port 80 on this machine, renews the   ."
echo ". certificates and disables the port again at the end.          ."
echo ".                                                               ."
echo ". Make sure to enable port 80 on your internet firewall before  ."
echo ". proceeding.                                                   ."
echo ".                                                               ."
echo "................................................................."
echo

read -p "Press enter to continue when you have enabled port 80 in your internet firewall"

sudo firewall-cmd --add-service=http
sudo firewall-cmd --list-all
sudo certbot renew
sudo firewall-cmd --remove-service=http
sudo firewall-cmd --list-all


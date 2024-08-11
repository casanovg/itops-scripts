#!/bin/sh

# Firerall setup for Seafile
# ......................................
# 2019-12-31 gustavo.casanova@gmail.com

sudo firewall-cmd --zone=public --permanent --add-port=8000/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8000/udp
sudo firewall-cmd --zone=public --permanent --add-port=8082/tcp
sudo firewall-cmd --zone=public --permanent --add-port=8082/udp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
sudo firewall-cmd --reload


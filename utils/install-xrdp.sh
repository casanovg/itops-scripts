#!/bin/sh

# Install xrdp (MS Remote Desktop Protocol)
# ..........................................
# 2019-12-29  gustavo.casanova@gmail.com

sudo dnf -y install xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo firewall-cmd --add-port=3389/tcp --permanent
sudo firewall-cmd --reload


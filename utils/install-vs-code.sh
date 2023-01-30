#!/bin/sh

# Install Visual Studio Code
# .......................................
# 2018-04-22  gustavo.casanova@gmail.com

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo dnf check-update
sudo dnf install -y code


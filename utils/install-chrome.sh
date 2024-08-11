#!/bin/sh

# Install Google Chrome
# .......................................
# 2018-04-22  gustavo.casanova@gmail.com

sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome

sudo cat << EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

sudo dnf install -y google-chrome-stable

# GDM configuration storage
#[daemon]
# Uncomment the line below to force the login screen to use Xorg
#WaylandEnable=false
#[security]


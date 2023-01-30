#!/bin/sh

# Install VirtualBox (on Fedora 37)
# .......................................
# 2023-01-16  gustavo.casanova@gmail.com

sudo dnf -y install @development-tools

sudo dnf -y install kernel-headers kernel-devel dkms elfutils-libelf-devel qt5-qtx11extras

sudo dnf -y install kernel-devel # kernel-devel-6.0.7-301.fc37.x86_64

cat <<EOF | sudo tee /etc/yum.repos.d/virtualbox.repo
[virtualbox]
name=Fedora \$releasever - \$basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/36/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc
EOF

sudo dnf -y search virtualbox

sudo dnf -y install VirtualBox-7.0



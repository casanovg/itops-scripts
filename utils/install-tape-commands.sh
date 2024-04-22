#!/bin/sh

# Install tape manipulation commands
# .......................................
# 2023-03-28 gustavo.casanova@gmail.com

sudo dnf -y install lsscsi mt-st dump rsh rsh-server
sudo systemctl enable rsh.socket rlogin.socket rexec.socket
sudo systemctl start rsh.socket rlogin.socket rexec.socket

echo
lsscsi -g
echo


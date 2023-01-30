#!/bin/sh

# Set the SetUID bit on 3 files to try to fix the
# "“user” CIFS mounts not supported" error when
# mounting a Windows share
# ........................................
# 2023-01-19 gustavo.casanova@gmail.com

sudo chmod u+s /bin/mount
sudo chmod u+s /bin/umount
sudo chmod u+s /usr/sbin/mount.cifs

#sudo mount -t cifs //HTA-DYP/SQLServer-Backup$ /mnt-backintime/sqlserver-backup -o username=itops,password=xxxxxxxx


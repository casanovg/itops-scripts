#!/bin/sh

# HTA-FileServer start
# ...........................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

# Mount HTA iscsi disk target
/root/iscsi-mount.sh;
sleep 5;
cd /root;
/root/fs-start.sh;
sleep 5;
/root/fs-stop.sh;
/root/fs-stop.sh;
sleep 5;
/root/fs-start.sh;

# NOTE: To let this script run without stops
# edit the "/etc/sudoers" to make the "wheel"
# group to run commands without password:
# %wheel  ALL=(ALL)       NOPASSWD: ALL

# Mount HTA serverfilesystems for backups
#su - netbackup;
#mount /mnt-backintime/hta-businessmate;
#mount /mnt-backintime/hta-mothership;
#mount /mnt-backintime/hta-opportunity;
#mount /mnt-backintime/hta-enterprise;
#exit;


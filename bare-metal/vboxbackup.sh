#!/bin/sh

#
# vboxbackup
# ===========================
# 2018-05-15 Gustavo Casanova
#

LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log'

# Copying the root folder to /data to be backed-up with backintime
#rm -rf /data/$(hostname -s)-root-folder/*
#sudo \cp -rf /root/* /data/$(hostname -s)-root-folder/
#chown -R netbackup:wheel /data/$(hostname -s)-root-folder/

#~/itops-scripts/bare-metal/vboxbkpactivevms.sh 1>>$LogFile 2>>$LogFile
#~/itops-scripts/bare-metal/vboxbkpinactivevms.sh 1>>$LogFile 2>>$LogFile
~/itops-scripts/bare-metal/vboxbkpvms-stopall.sh 1>>$LogFile 2>>$LogFile

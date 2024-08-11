#!/bin/sh

# This script runs a specific backup script and logs the output
# ..............................................................
# 2018-05-15 gustavo.casanova@gmail.com

LogFile='/data/VirtualBox-Exports/Log/vboxbackup.log'

# Copying the root folder to /data to be backed-up with backintime
#rm -rf /data/$(hostname -s)-root-folder/*
#sudo \cp -rf /root/* /data/$(hostname -s)-root-folder/
#chown -R netbackup:wheel /data/$(hostname -s)-root-folder/

#~/itops-scripts/physical-machines/vboxbkpactivevms.sh 1>>$LogFile 2>>$LogFile
#~/itops-scripts/physical-machines/vboxbkpinactivevms.sh 1>>$LogFile 2>>$LogFile
~/itops-scripts/physical-machines/vboxbkpvms-stopall.sh 1>>$LogFile 2>>$LogFile

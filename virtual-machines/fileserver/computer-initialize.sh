#!/bin/sh

# Initialize HTA-FileServer Services
# ......................................
# 2018-05-25 gustavo.casanova@gmail.com

ComputerLog="/home/netbackup/computer-control.log"
clear
echo ""
echo "********************************************************************************"
echo "* `hostname -s | tr [a-z] [A-Z]` Server Initialization Sequence"
echo "********************************************************************************"
echo ""
echo ">>> `hostname -s | tr [a-z] [A-Z]` server initialization sequence started on `date` ..." >> $ComputerLog
echo ""
echo "Mounting iscsi disks ..."
sudo /root/iscsi-mount.sh
echo ""
echo "Starting SMB services for HTA network folders ..."
sudo /root/fs-start.sh
sleep 3
sudo /root/fs-stop.sh
sleep 3
sudo /root/fs-start.sh
sleep 3
#su netbackup /home/netbackup/bkp-mount.sh
/home/netbackup/bkp-mount.sh
echo ">>> `hostname -s | tr [a-z] [A-Z]` server initialization sequence completed on `date`!" >> $ComputerLog

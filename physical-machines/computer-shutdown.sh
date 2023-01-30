#!/bin/sh

# Shutdown Physical Server Services
# ......................................
# 2018-05-25 gustavo.casanova@gmail.com

ComputerLog="~/computer-control.log"
clear
echo ""
echo "********************************************************************************"
echo "* $(hostname -s | tr [a-z] [A-Z]) Server Shutdown Sequence"
echo "********************************************************************************"
echo ""
echo ">>> $(hostname -s | tr [a-z] [A-Z]) server shutdown sequence initiated on $(date) ..." >>$ComputerLog
# su netbackup /home/netbackup/bkp-umount
# sleep 2
# echo ""
# echo "Stopping HTA network folders SMB services ..."
# ~/itops-scripts/fileserver-vm/fs-stop.sh 1>>/dev/null 2>>/dev/null
# echo "."
# sleep 2
# ~/itops-scripts/fileserver-vm/fs-stop.sh 1>>/dev/null 2>>/dev/null
# echo "."
# echo ""
# echo "Turning all Virtual Machines off, please wait ..."
# echo ""
~/itops-scripts/physical-machines/vboxall-off.sh
# ~/itops-scripts/physical-machines/acc-off.sh
sleep 5
echo ""
echo "All VirtualBox Virtual Machines stopped ..."
echo ""
echo "Shutting-down $(hostname -s | tr [a-z] [A-Z]) Server ..."
echo ""
echo ">>> $(hostname -s | tr [a-z] [A-Z]) server shutdown sequence completed on $(date), turning computer off!" >>$ComputerLog
sudo shutdown
# echo "Rebooting `hostname -s | tr [a-z] [A-Z]` Server ..."
# echo ""
# sudo shutdown -r
# echo ">>> `hostname -s | tr [a-z] [A-Z]` server shutdown sequence completed on `date`, rebooting computer!" >> $ComputerLog

#
# Shutdown HTA-Mothership Server Services
# =======================================
# 2018-05-25 Gustavo Casanova
#
clear
ComputerLog="/home/netbackup/computer-control.log"
echo ""
echo "********************************************************************************"
echo "* `hostname -s | tr [a-z] [A-Z]` Server Shutdown Sequence"
echo "* -----------------------------------------------------------------------------"
echo "* 2018-05-25 Gustavo Casanova (gcasanova@hellermanntyton.com.ar)"
echo "********************************************************************************"
echo ""
echo ">>> `hostname -s | tr [a-z] [A-Z]` server shutdown sequence initiated on `date` ..." >> $ComputerLog
su netbackup /home/netbackup/bkp-umount
sleep 2
echo ""
echo "Stopping HTA network folders SMB services ..."
sudo /root/fs-stop 1>>/dev/null 2>>/dev/null
echo "."
sleep 2
sudo /root/fs-stop 1>>/dev/null 2>>/dev/null
echo "."
echo ""
echo "Turning all Virtual Machines off, please wait ..."
echo ""
sudo /root/vboxall-off
sudo /root/acc-off
sleep 60
echo ""
echo "All VirtualBox Virtual Machines stopped ..."
echo ""
echo "Shutting-down `hostname -s | tr [a-z] [A-Z]` Server ..."
echo ""
echo ">>> `hostname -s | tr [a-z] [A-Z]` server shutdown sequence completed on `date`, turning computer off!" >> $ComputerLog
sudo shutdown
# echo "Rebooting `hostname -s | tr [a-z] [A-Z]` Server ..."
# echo ""
# sudo shutdown -r
# echo ">>> `hostname -s | tr [a-z] [A-Z]` server shutdown sequence completed on `date`, rebooting computer!" >> $ComputerLog


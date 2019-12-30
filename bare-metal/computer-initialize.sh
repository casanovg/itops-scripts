#
# Initialize Bare-Metal Server Services
# =====================================
# 2018-05-25 Gustavo Casanova
#
ComputerLog="~/computer-control.log"
clear
echo ""
echo "********************************************************************************"
echo "* $(hostname -s | tr [a-z] [A-Z]) Server Initialization Sequence"
echo "* -----------------------------------------------------------------------------"
echo "* 2018-05-25 Gustavo Casanova (gcasanova@hellermanntyton.com.ar)"
echo "********************************************************************************"
echo ""
echo ">>> $(hostname -s | tr [a-z] [A-Z]) server initialization sequence started on $(date) ..." >>$ComputerLog
echo "Turning all Virtual Machines on, please wait ..."
echo ""
~/itops-scripts/bare-metal/vboxall-on.sh
# ~/itops-scripts/bare-metal/acc-on.sh
echo ""
# echo "Waiting 2 minutes until domain services are up ..."
# sleep 120
# echo ""
# echo "Starting SMB services for HTA network folders ..."
# ~/itops-scripts/fileserver-vm/fs-start.sh
# sleep 3
# ~/itops-scripts/fileserver-vm/fs-stop.sh
# sleep 3
# ~/itops-scripts/fileserver-vm/fs-start.sh
# sleep 3
# ~/home/netbackup/bkp-mount.sh
echo ">>> $(hostname -s | tr [a-z] [A-Z]) server initialization sequence completed on $(date)!" >>$ComputerLog

#!/bin/sh

# Stop all virtual machines and reboot server
# ............................................
# 2019-12-29 gustavo.casanova@gmail.com

source ~/itops-scripts/common/set-env.sh
source ~/itops-scripts/common/set-vm-lists.sh

# Stop all virtual machines
echo ""
echo "Stopping virtual machines ..."
~/"$GIT_REP"/"$PHY_SVR_SCRIPTS"/vboxall-off.sh
# Stopping essential net services
echo "Stopping $ESSENTIAL_NET_SERVICE essential network services, Bye!"
echo ""
~/"$GIT_REP"/"$PHY_SVR_SCRIPTS"/vm-off.sh "$ESSENTIAL_NET_SERVICE"
sleep 3
# Reboot
echo ""
echo "Shutting down ..."
sudo shutdown -r now
# Start all virtual machines (in case that reboot fails)
sleep 180
echo ""
echo "Starting virtual machines ..."
~/"$GIT_REP"/"$PHY_SVR_SCRIPTS"/vboxall-on.sh

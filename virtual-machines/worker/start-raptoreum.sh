#!/bin/sh

# Start raptoreum daemon & work services
# .......................................
# 2022-02-22 Worker's union 

WORKER_APP="xmrig"
WORKER_BAS="/data"
WALLET_DIR="$WORKER_BAS/raptoreum-wallet"
HOST_NAME=$(awk -F= '/PRETTY/ {print $2}' /etc/machine-info)

sleep 5

# Setting worker keymap (latam, es, us)
# sudo localectl list-keymaps
sudo localectl set-keymap latam

# Start raptoreum daemon
echo ""
echo "Starting raptoreum daemon"
echo "........................."
$WALLET_DIR/raptoreumd &
echo ""

# Start worker application
echo ""
echo "Initializing worker application"
echo "..............................."
echo ""
screen -S worker -dm sudo $WORKER_BAS/latest-worker/$WORKER_APP
echo ""

# Console info
#sudo bash -c 'HOST_NAME="$(hostname -s)"; echo "" > /dev/tty1; echo "" > /dev/tty1; cowsay "$(echo ${HOST_NAME^^} started!; echo ""; date +%F" "%R)" > /dev/tty1; echo "" > /dev/tty1'


#!/bin/sh

# Update worker application
# ..........................
# 2022-02-22 Worker's union

WORKER_APP="xmrig"
WORKER_VER="6.16.4"

HOST_NAME=$(awk -F= '/PRETTY/ {print $2}' /etc/machine-info)
WORKER_BAS="/data"
WORKER_LNK="https://github.com/$WORKER_APP/$WORKER_APP/releases/download/v$WORKER_VER"
WORKER_FIL="$WORKER_APP-$WORKER_VER-linux-static-x64.tar.gz"
WORKER_DIR="$WORKER_APP-$WORKER_VER"
WORKER_CFG="config.json"

echo ""
echo "Downloading worker application"
echo ".............................."
echo ""
cd $WORKER_BAS
wget $WORKER_LNK/$WORKER_FIL
echo ""
echo "Uncompressing files"
echo "..................."
echo
tar xzvf ./$WORKER_FIL
echo ""
echo "Configuring the worker for Flockpool"
echo "...................................."
mv $WORKER_BAS/$WORKER_DIR/$WORKER_CFG $WORKER_BAS/$WORKER_DIR/$WORKER_CFG.orig
source ~/itops-scripts/virtual-machines/worker/configure-flockpool.sh
echo ""
echo "Creating link to the latest version"
echo "..................................."
echo
rm $WORKER_BAS/$WORKER_DIR $WORKER_BAS/latest-worker 1>/dev/null 2>/dev/null 
ln -s $WORKER_BAS/$WORKER_DIR $WORKER_BAS/latest-worker
# echo ""
echo "Removing compressed file"
echo "........................"
rm -rf $WORKER_BAS/*.tar.gz 1>/dev/null 2>/dev/null
rm -rf $WORKER_BAS/*.tar.gz.* 1>/dev/null 2>/dev/null
echo ""
echo "Done!"
echo ""

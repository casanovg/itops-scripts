#!/bin/sh

# Wallet backup
# ..........................
# 2022-02-22 Worker's union

BASE_DIR="data"
WALLET_BKP_DIR="raptoreum-wallet/wallet-backups"
WALLET_AUT_DIR=".raptoreumcore/backups"
VARIOUS_DIR="various"
DEST_SERVER="10.6.17.30"
DEST_FOLDER="data/old-businessmate/w-backup"

rsync -r -a -v --info=progress2 /$BASE_DIR/$WALLET_BKP_DIR/* $DEST_SERVER:/$DEST_FOLDER/.
rsync -r -a -v --info=progress2 /$BASE_DIR/$WALLET_AUT_DIR $DEST_SERVER:/$DEST_FOLDER/.
rsync -r -a -v --info=progress2 /$BASE_DIR/$VARIOUS_DIR/* $DEST_SERVER:/$DEST_FOLDER/.


#!/bin/sh

# Script to synchronize and close a remote machine's wllt
# ........................................................
# 2023-06-27 gustavo.casanova@gmail.com

REMOTE_USR="netbackup"
WLL_MACHINE="10.77.77.77"
WLL_PR_NAME="raptoreum-qt"

RPID=$(ssh $REMOTE_USR@$WLL_MACHINE "pgrep $WLL_PR_NAME")
ssh $REMOTE_USR@$WLL_MACHINE "kill $RPID"
sleep 15
ssh $REMOTE_USR@$WLL_MACHINE "sudo shutdown -r now"


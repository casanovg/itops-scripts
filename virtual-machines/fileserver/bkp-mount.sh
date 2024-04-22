#!/bin/sh

# Mount network shares for backup
# ......................................
# 2018-05-16 gustavo.casanova@gmail.com

echo ""
echo "Connecting network shares to /mnt-backintime directory ..."
echo ""
sleep 1
sleep 1
echo "Mounting HTA-BusinessMate ..."
mount /mnt-backintime/hta-businessmate
echo "."
sleep 1
echo "Mounting HTA-Mothership ..."
mount /mnt-backintime/hta-mothership
echo "."
sleep 1
echo "Mounting HTA-Opportunity ..."
mount /mnt-backintime/hta-opportunity
echo "."
sleep 1

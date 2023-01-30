#!/bin/sh

# Umount network shares for backup
# ......................................
# 2018-05-16 gustavo.casanova@gmail.com

echo ""
echo "Disconnecting network shares to /mnt-backintime directory ..."
echo ""
sleep 1
echo "Unmounting HTA-BusinessMate ..."
umount /mnt-backintime/hta-businessmate
echo "."
sleep 1
echo "Unmounting HTA-Mothership ..."
umount /mnt-backintime/hta-mothership
echo "."
sleep 1
echo "Unmounting HTA-Opportunity ..."
umount /mnt-backintime/hta-opportunity
echo "."
sleep 1

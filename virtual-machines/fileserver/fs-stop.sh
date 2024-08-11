#!/bin/sh

# HTA filesystem stop
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

echo ""
if [ -z "$(sudo ps -C nmbd -o pid | grep -v PID)" ]; then
     echo "nmdb process already stopped ..."
else
     echo "Stopping nmdb process ..."
     sudo kill $(sudo ps -C nmbd -o pid | grep -v PID)
fi

echo ""
if [ -z "$(sudo ps -C smbd -o pid | grep -v PID)" ]; then
     echo "smdb process already stopped ..." 
else
     echo "Stopping smdb process ..."
     sudo kill $(sudo ps -C smbd -o pid | grep -v PID)
fi

echo ""
if [ -z "$(sudo ps -C winbindd -o pid | grep -v PID)" ]; then
     echo "winbindd process already stopped ..."
else
     echo "Stopping winbindd process ..."
     sudo kill $(sudo ps -C winbindd -o pid | grep -v PID)
fi

sudo ps ax | egrep "samba|smbd|nmbd|winbindd" | grep -v grep
echo ""

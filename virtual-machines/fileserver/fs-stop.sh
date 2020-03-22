#!/bin/sh

# HTA filesystem stop
# ...........................................
# 2019-12-09 gcasanova@hellermanntyton.com.ar

sudo kill $(sudo ps -C nmbd -o pid | grep -v PID)
sudo kill $(sudo ps -C smbd -o pid | grep -v PID)
sudo kill $(sudo ps -C winbindd -o pid | grep -v PID)
sudo ps ax | egrep "samba|smbd|nmbd|winbindd" | grep -v grep

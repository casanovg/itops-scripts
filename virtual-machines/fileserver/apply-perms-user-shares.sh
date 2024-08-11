#!/bin/sh

# Set AD permissions to users' personal net folders
# ......................................i...........
# 2023-05-15 gustavo.casanova@gmail.com

USR_FLD_PTH="/data/netfiles-disk/hta-users"

for USER in $(ls -1 $USR_FLD_PTH); do
       echo "Applying permissions to $USER personal folder"
       sudo chown -R "HTAR\\$USER":wheel $USR_FLD_PTH/"$USER"/
       sleep 1
done


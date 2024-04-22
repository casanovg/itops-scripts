#!/bin/sh

# Set HTA users home dirs permissions
# ......................................
# 2020-01-03 gustavo.casanova@gmail.com

for OWNER in `ls -1 /data/aleph-disk/hta-users`; do
       	chown -R HTARGENTINA\\$OWNER /data/aleph-disk/hta-users/$OWNER;
done

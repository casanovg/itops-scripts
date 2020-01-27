#!/bin/sh

# Set HTA users home dirs permissions
# ...........................................
# 2020-01-03 gcasanova@hellermanntyton.com.ar
# ...........................................

for OWNER in `ls -1 /data/aleph-disk/hta-users`; do
       	chown -R HTARGENTINA\\$OWNER /data/aleph-disk/hta-users/$OWNER;
done

#!/bin/sh

# Mount iso disk images directly, without
# sharing them as iscsi targets
# ........................................
# 2019-12-21 gustavo.casanova@gmail.com

mount -t xfs -o loop,offset=8388608,ro /data/iscsi-targets/aleph-backup.img /mnt

# Umount:
# .......
# umount /mnt
# losetup -d /dev/loop0

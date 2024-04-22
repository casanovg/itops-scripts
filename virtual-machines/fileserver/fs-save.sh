#!/bin/sh

# HTA filesystem save
# ......................................
# 2019-12-17 gustavo.casanova@gmail.com

rsync -r -a /data/aleph-disk/* root@10.6.17.70:/mnt/hta-nasvol01/hta-fileserver/.
rsync -r /data/taxpy-disk/* root@10.6.17.70:/mnt/hta-nasvol01/hta-var/.


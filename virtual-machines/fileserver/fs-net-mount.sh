#!/bin/sh

# HTA filesystem network mount
# ......................................
# 2019-12-09 gustavo.casanova@gmail.com

mount -t cifs //hta-fileserver/HTA-Root$ /mnt/file-server -o user=HTARGENTINA\\administrator,vers=3.0

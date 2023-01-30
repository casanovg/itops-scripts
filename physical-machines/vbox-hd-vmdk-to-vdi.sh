#!/bin/sh

# Convert a .vmdk VM disk to .vdi
# ......................................
# 2018-05-19 gustavo.casanova@gmail.com

VBoxManage clonehd --format VDI "NB-DevUx03-disk1.vmdk" "NB-DevUx03-disk1.vdi"

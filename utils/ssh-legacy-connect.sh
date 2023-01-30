#!/bin/bash

# ssh connection hosts using legacy algorithms support (e.g. OpenWRT)
# ....................................................................
# 2022-07-27 gustavo.casanova@gmail.com

ssh -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-dss $1@$2 $3

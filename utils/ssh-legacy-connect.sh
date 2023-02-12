#!/bin/bash

# ssh connection hosts using legacy algorithms support (e.g. OpenWRT)
# ....................................................................
# 2022-07-27 gustavo.casanova@gmail.com

# OpenWRT router (id: root)
#ssh -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa "$1"@$2 $3

# Askey RTF8115VW (Movistar fiber router - id: admin):
ssh -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa "$1"@$2

# Other equipment
#ssh -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-dss "$1"@$2 $3


#!/bin/bash

# Power HTA-Mothership server on (iLO4 ssh)
# ..........................................
# 2023-10-16

USR="netbackup"
ILO_MS_IP="10.6.17.252"
ILO4_PWR_ON="POWER ON"

ssh -o KexAlgorithms=diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedKeyTypes=+ssh-rsa $USR@$ILO_MS_IP $ILO4_PWR_ON


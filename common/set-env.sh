#!/bin/sh

# Common environment settings
# ...........................................
# 2019-12-31 gcasanova@hellermanntyton.com.ar

GIT_REP="itops-scripts"
COMMON_SCRIPTS="common"
PHY_SVR_SCRIPTS="bare-metal"
FILES_VM_SCRIPTS="fileserver-vm"
UTILS_SCRIPTS="utils"

ACTIVE_VMS=$(cat ~/ActiveVMs)
ESSENTIAL_NET_SERVICE="$(cat ~/EssentialNetServices)"

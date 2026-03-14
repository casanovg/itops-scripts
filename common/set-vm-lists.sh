#!/bin/sh

# Common virtual machine list settings
# ...........................................
# 2020-01-03 gustavo.casanova@gmail.com

ACTIVE_VMS=$(grep -v '^#' ~/ActiveVMs)
ESSENTIAL_NET_SERVICE="$(grep -v '^#' ~/EssentialNetServices)"

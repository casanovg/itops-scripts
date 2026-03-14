#!/bin/sh

# Common virtual machine list settings
# ...........................................
# 2020-01-03 gustavo.casanova@gmail.com

ACTIVE_VMS=$([ -f ~/ActiveVMs ] && grep -v '^#' ~/ActiveVMs || echo "Warning: ~/ActiveVMs not found, ignoring." >&2)
ESSENTIAL_NET_SERVICE="$([ -f ~/EssentialNetServices ] && grep -v '^#' ~/EssentialNetServices || echo "Warning: ~/EssentialNetServices not found, ignoring." >&2)"

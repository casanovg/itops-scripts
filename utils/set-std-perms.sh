#!/bin/sh

# Script to apply standard permissions to files and folder from path downwards
# .............................................................................
# 2023-05-22 gustavo.casanova@gmail.com

DST_PATH=$1
FIL_MODE=644
DIR_MODE=755

if [ $# -eq 0 ] || [ -z "$1" ]
  then
    echo ""
    echo "Usage: set-std-perms.sh <PATH>"
    echo ""
else
    echo
    echo "Applying standard persmissions to $DST_PATH ..."
    find $DST_PATH -type d -exec chmod $DIR_MODE {} +
    find $DST_PATH -type f -exec chmod $FIL_MODE {} +
    echo
    echo "Done!"
    echo
fi


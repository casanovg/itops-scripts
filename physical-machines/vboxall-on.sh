#!/bin/sh

# Script to power on all required virtual machines
# .................................................
# 2019-12-29 gustavo.casanova@gmail.com

POST_START_DLY=120
IFS=$'\n'

for VM in $(cat ~/ActiveVMs); do
        echo "Starting VM: $VM"
        ~/itops-scripts/physical-machines/vm-on.sh "$VM"
        RC=$?
        case $RC in
                0)
                        echo "Waiting $POST_START_DLY seconds for $VM services startup ..."
                        sleep $POST_START_DLY
                        ;;
                1)
                        echo "$VM already running, skipping delay"
                        ;;
                *)
                        echo "Warning: $VM failed to start (exit $RC), continuing with next VM"
                        ;;
        esac
        echo ""

done
echo "All virtual machines processed"

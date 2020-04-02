#!/bin/sh

# *******************************************
# * Script to power internet servers VMs on *
# * ======================================= *
# * 2020-04-02 Gustavo Casanova             *
# * gcasanova@hellermanntyton.com.ar        *
# *******************************************

source ~/itops-scripts/common/set-env.sh

for INTERNET in "HTA-Firewall" "HTA-NetPal"; do

        EXIT_CODE=0
        VM=$(vboxmanage list vms | gawk -F\" '{print $(NF-1)}' | grep -w "^$INTERNET$")
        if [ ! -z "$VM" ]; then
                RUNNING_VM=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$")
                if [ -z "$RUNNING_VM" ]; then
                        echo ""
                        echo "$VM virtual machine inactive, trying to power it on ..."
                        vboxmanage startvm "$VM" --type headless
                else
                        echo ""
                        echo "$RUNNING_VM virtual machine already active!"
                        EXIT_CODE=1
                fi
        else
                echo ""
                echo "$INTERNET virtual machine not found!"
                EXIT_CODE=2
        fi
        sleep 3
done

echo ""
exit $EXIT_CODE


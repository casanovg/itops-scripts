#!/bin/sh

# Script to power on all required virtual machines
# .................................................
# 2019-12-29 gustavo.casanova@gmail.com

#!/bin/sh

POST_START_DLY=120
IFS=$'\n'

for VM in $(cat ~/ActiveVMs); do
	~/itops-scripts/physical-machines/vm-on.sh "$VM"
	if [ $? -eq 0 ]; then
		echo "Waiting $POST_START_DLY seconds for VM's services startup ..."
		sleep $POST_START_DLY
	fi
done
echo "All virtual machines started!"
# echo ""


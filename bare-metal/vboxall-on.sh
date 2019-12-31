#!/bin/sh

# *****************************************************
# * Script to power on all necessary virtual machines *
# * ================================================= *
# * 2019-12-29 Gustavo Casanova                       *
# * gcasanova@hellermanntyton.com.ar                  *
# *****************************************************

source ~/itops-scripts/common/set-env.sh

POST_START_DLY=60
IFS=$'\n'

for VM in $(cat ~/ActiveVMs); do
	~/"$GIT_REP"/"$PHY_SVR_SCRIPTS"/vbox-on.sh "$VM"
	if [ $? -eq 0 ]; then
		echo "Waiting $POST_START_DLY seconds for VM's services startup ..."
		sleep $POST_START_DLY
	fi
done
echo "All virtual machines started!"
echo ""

#VM_FILE=~/ActiveVMs
# while read VM; do
# 	echo ""
# 	#vboxmanage startvm $virtualmachine --type headless
# 	~/itops-scripts/bare-metal/vbox-on.sh "$VM"
# 	echo "Waiting 2 minutes for VM's services startup ..."
# 	sleep 30
# done <$VM_FILE

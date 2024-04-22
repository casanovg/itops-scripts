#!/bin/sh

# Stop all virtual machines and shut down this server
# in response to a command from the APC UPS via Powerchute
# .............................................................
# NOTE: This script is to be run under the 'root' user context
# .............................................................
# 2023-02-05 gustavo.casanova@gmail.com

IFS=$'\n'

ComputerLog="/home/netbackup/ups-control.log"

echo "........................................................................................................................" >> $ComputerLog;
echo ">>> $(hostname -s | tr [a-z] [A-Z]) server shutdown sequence initiated by UPS on $(date) ..." >> $ComputerLog;


if command -v vboxmanage &> /dev/null; then
        if [ ! -n "$(vboxmanage --version | grep "WARNING")" ]; then
        
		echo "Apagando las maquinas virtuales"


		for VM in $(sudo -H -u netbackup bash -c "vboxmanage list runningvms" | gawk -F\" '{print $(NF-1)}') ; do
	
			WAIT_TIME=180	# Time to wait for machine shutdown in seconds

			echo "Shutting $VM down ...";
			echo "Shutting $VM down on $(date "+%b %d, %Y - %T")..." >> $ComputerLog;
		
			sudo -H -u netbackup bash -c "vboxmanage controlvm $VM acpipowerbutton"
			sleep 2
			sudo -H -u netbackup bash -c "vboxmanage controlvm $VM acpipowerbutton"

			RUNNING_VM=$VM
			while [[ "$RUNNING_VM" && $WAIT_TIME -gt 0 ]]; do
				RUNNING_VM="$(sudo -H -u netbackup bash -c "vboxmanage list runningvms"| gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$" )"
				if [ "$RUNNING_VM" ]; then
					echo "$RUNNING_VM still on, waiting $WAIT_TIME seconds ..."
				fi
	        	    	((WAIT_TIME = WAIT_TIME - 1))
		            	sleep 1
				if [ $WAIT_TIME == 0 ]; then
					echo
					echo ">>> Timeout: $WAIT_TIME for $VM, moving on ... <<<"
				fi
		       	done
		       	echo ""

		done

        fi
fi

# Shut down
echo "Shutting down this server ..."
echo ">>> $(hostname -s | tr [a-z] [A-Z]) server shutdown sequence by UPS completed on $(date), turning computer off!" >>$ComputerLog;
echo "........................................................................................................................" >> $ComputerLog;
sudo shutdown now "Emergency shutdown initiated by the UPS!"


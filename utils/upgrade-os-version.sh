#!/bin/sh

# Upgrade the operating system to a newer version
# ...............................................
# 2024-10-29 gustavo.casanova@gmail.com

#!/bin/bash

# Default version if no argument is provided
NEWVERSION=${NEWVERSION:-41}

# If a command line argument is provided, override NEWVERSION with it
if [ ! -z "$1" ]; then
    NEWVERSION=$1
fi

# Get the current Fedora version
CURRENT_VERSION=$(grep -oP '(?<=^VERSION_ID=)\d+' /etc/os-release)

# Check if the target version is less than the current version
if (( NEWVERSION < CURRENT_VERSION )); then
    echo
    echo "Downgrade is not supported. You are currently running Fedora version $CURRENT_VERSION."
    echo
    exit 1
fi

# Prompt the user for confirmation before proceeding
echo
read -p "Are you sure you want to upgrade Fedora to version $NEWVERSION? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Upgrade canceled."
    exit 0
fi

echo
echo "Preparing to upgrade Fedora to version $NEWVERSION..."

# Check if VirtualBox is installed and running
if command -v vboxmanage &> /dev/null; then
    # Check if there are no warnings from VirtualBox, indicating it's in a stable state
    if [ ! -n "$(vboxmanage --version | grep "WARNING")" ]; then

        echo "Shutting down virtual machines..."

        # List all running VMs and shut each down gracefully
        for VM in $(sudo -H -u netbackup bash -c "vboxmanage list runningvms" | gawk -F\" '{print $(NF-1)}') ; do

            WAIT_TIME=180   # Time to wait for machine shutdown in seconds

            echo "Shutting $VM down ..."
            echo "Shutting $VM down on $(date "+%b %d, %Y - %T")..." >> $ComputerLog;

            # Send the ACPI power button signal to shut down the VM
            sudo -H -u netbackup bash -c "vboxmanage controlvm $VM acpipowerbutton"
            sleep 2
            sudo -H -u netbackup bash -c "vboxmanage controlvm $VM acpipowerbutton"

            # Wait for the VM to completely shut down or timeout
            RUNNING_VM=$VM
            while [[ "$RUNNING_VM" && $WAIT_TIME -gt 0 ]]; do
                RUNNING_VM="$(sudo -H -u netbackup bash -c "vboxmanage list runningvms" | gawk -F\" '{print $(NF-1)}' | grep -w "^$VM$" )"
                if [ "$RUNNING_VM" ]; then
                    echo "$RUNNING_VM still on, waiting $WAIT_TIME seconds ..."
                fi
                ((WAIT_TIME = WAIT_TIME - 1))
                sleep 1
                if [ $WAIT_TIME == 0 ]; then
                    echo
                    echo ">>> Timeout reached: $WAIT_TIME seconds for $VM, moving on ... <<<"
                fi
            done
            echo ""
        done
    fi
fi

# Refresh repositories and clear DNF cache
sudo dnf upgrade --refresh -y

# Install DNF plugin for system upgrades if not already installed
sudo dnf install dnf-plugin-system-upgrade -y

# Start the system upgrade
sudo dnf system-upgrade download --releasever=$NEWVERSION -y

# Check if the download was successful before rebooting
if [ $? -eq 0 ]; then
    echo
    echo "System upgrade to Fedora $NEWVERSION is ready. Rebooting..."
    sudo dnf system-upgrade reboot
else
    echo
    echo "Error: System upgrade failed. Check your network connection or version compatibility."
fi

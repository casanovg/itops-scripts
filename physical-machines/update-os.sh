#!/bin/sh

# Update OS and reboot
# ......................................
# 2019-12-24 gustavo.casanova@gmail.com

source ~/itops-scripts/common/set-vm-lists.sh

# Function to check if VBox is installed and working without warnings
vbox_ready() {
    command -v vboxmanage &> /dev/null && ! vboxmanage --version 2>&1 | grep -q "WARNING"
}

# Ensure dnf-plugins-core is installed
if ! rpm -q dnf-plugins-core &> /dev/null; then
    echo "Installing dnf-plugins-core..."
    sudo dnf install -y dnf-plugins-core > /dev/null
fi

# Update OS
echo ""
echo "Looking for updates ..."
# We store the output to check if VirtualBox was among the updated packages
UPDATE_LOG=$(sudo dnf update --refresh -y)
echo "$UPDATE_LOG"

# Check if VirtualBox was updated in this transaction
VBOX_UPDATED=1
if echo "$UPDATE_LOG" | grep -qi "VirtualBox"; then
    VBOX_UPDATED=0
fi

# Determine if system reboot is required
sudo dnf needs-restarting -r > /dev/null 2>&1
SYSTEM_REBOOT_REQUIRED=$?

# DECISION LOGIC: Should we stop VMs?
# We stop them ONLY if the system needs a reboot OR VirtualBox itself was updated
if [ $SYSTEM_REBOOT_REQUIRED -eq 1 ] || [ $VBOX_UPDATED -eq 0 ]; then
    
    if vbox_ready; then
        echo ""
        echo "Reboot or VBox update detected. Stopping virtual machines..."
        ~/itops-scripts/physical-machines/vboxall-off.sh
        
        if [ $SYSTEM_REBOOT_REQUIRED -eq 1 ]; then
            # Stopping essential net services before reboot
            echo "Stopping $ESSENTIAL_NET_SERVICE essential network services..."
            ~/itops-scripts/physical-machines/vm-off.sh "$ESSENTIAL_NET_SERVICE"
            sleep 3
            
            echo "Rebooting required. Restarting now..."
            sudo shutdown -r now
        else
            # VBox was updated but no system reboot needed
            # We just restart VBox services/modules and turn VMs back on
            echo "VirtualBox was updated. Restarting VBox kernel modules..."
            sudo /sbin/vboxconfig || sudo systemctl restart vboxdrv
            ~/itops-scripts/physical-machines/vboxall-on.sh
        fi
    fi
else
    echo ""
    echo "No critical updates or VBox changes. No reboot needed. VMs kept running."
fi


#!/bin/sh

# Update OS and reboot - NB-Spirit variant
# ......................................
# 2019-12-24 gustavo.casanova@gmail.com
#
# NB-Spirit hosts the firewall VM for 10.77.77.0/24, so powering off all
# guests also powers off that firewall and the host loses its uplink on
# the production NIC. During the update this script temporarily uses the
# maintenance NIC (where an alternate firewall exists), then reverts to
# the production NIC before rebooting or restarting guests.
# Production NIC: eno8. Maintenance NIC: eno5.
# Order implemented below: stop guests, use maintenance uplink, refresh
# packages, restore production uplink, then reboot only if required.

source ~/itops-scripts/common/set-vm-lists.sh

# Function to check if VBox is installed and working without warnings
vbox_ready() {
    command -v vboxmanage &> /dev/null && ! vboxmanage --version 2>&1 | grep -q "WARNING"
}

switch_to_maintenance_net() {
    echo "Switching uplink to maintenance NIC (10.6.17.0/24) ..."
    sudo nmcli device connect eno5
    sudo nmcli device disconnect eno8
}

restore_production_net() {
    echo "Restoring uplink to production NIC (10.77.77.0/24) ..."
    sudo nmcli device connect eno8
    sudo nmcli device disconnect eno5
}

# Ensure dnf-plugins-core is installed
if ! rpm -q dnf-plugins-core &> /dev/null; then
    echo "Installing dnf-plugins-core..."
    sudo dnf install -y dnf-plugins-core > /dev/null
fi

# Spirit: stop ALL guests FIRST, including the essential net service.
# The refresh below must run with zero running VMs: if VirtualBox itself
# is among the packages to update, the transaction fails while guests run.
# (The vboxall-off helper skips the essential service, so it is stopped
# explicitly here. The reboot path later needs no second stop.)
if vbox_ready; then
    echo ""
    echo "Stopping ALL virtual machines before update (Spirit)..."
    ~/itops-scripts/physical-machines/vboxall-off.sh
    if [ -n "$ESSENTIAL_NET_SERVICE" ]; then
        for SVC in $ESSENTIAL_NET_SERVICE; do
            ~/itops-scripts/physical-machines/vm-off.sh "$SVC"
        done
        sleep 3
    fi
    if vboxmanage list runningvms | grep -q '"'; then
        echo "ERROR: some VMs are still running, aborting update to protect VirtualBox."
        vboxmanage list runningvms
        exit 1
    fi
    echo "No running VMs. Proceeding with update."
fi

# Switch uplink so the refresh still has internet without the local firewall guest
switch_to_maintenance_net
# Guarantee the NICs are reverted even if the refresh or checks fail
trap restore_production_net EXIT INT TERM

# Update OS
echo ""
echo "Looking for updates ..."
# We store the output to check if VirtualBox was among the updated packages
UPDATE_LOG=$(sudo dnf -y update --refresh)
UPDATE_RC=$?
echo "$UPDATE_LOG"
if [ $UPDATE_RC -ne 0 ]; then
    echo "Warning: package refresh exited with code $UPDATE_RC, continuing to revert uplink and evaluate reboot..."
fi

# Check if VirtualBox was updated in this transaction
VBOX_UPDATED=1
if echo "$UPDATE_LOG" | grep -qi "VirtualBox"; then
    VBOX_UPDATED=0
fi

# Determine if system reboot is required
sudo dnf needs-restarting -r > /dev/null 2>&1
SYSTEM_REBOOT_REQUIRED=$?

# Revert to the production uplink before reboot vs. restart decision,
# so the host ends on the production NIC either way.
trap - EXIT INT TERM
restore_production_net

# Validations from the base script: reboot only if the system requires it;
# restart VirtualBox modules and guests only if VirtualBox was updated.
# Single reboot path and single guest-start path on purpose.
if [ $SYSTEM_REBOOT_REQUIRED -eq 1 ]; then
    # All guests (including the essential net service) were already stopped
    # before the refresh, so reboot directly with the production uplink.
    echo "Rebooting required. Restarting now..."
    sudo shutdown -r now
else
    if [ $VBOX_UPDATED -eq 0 ]; then
        # VBox was updated but no system reboot needed
        echo "VirtualBox was updated. Restarting VBox kernel modules..."
        sudo /sbin/vboxconfig || sudo systemctl restart vboxdrv
    else
        echo ""
        echo "No critical updates or VBox changes. No reboot needed."
    fi
    # Guests were stopped up front, so bring them back in every non-reboot path.
    # vboxall-on covers ActiveVMs; ensure the essential service is also back
    # in case it is not listed there.
    if vbox_ready; then
        ~/itops-scripts/physical-machines/vboxall-on.sh
        if [ -n "$ESSENTIAL_NET_SERVICE" ]; then
            for SVC in $ESSENTIAL_NET_SERVICE; do
                if ! vboxmanage list runningvms | grep -qw "$SVC"; then
                    ~/itops-scripts/physical-machines/vm-on.sh "$SVC"
                fi
            done
        fi
    fi
fi

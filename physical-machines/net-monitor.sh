#!/bin/sh

# Script to check and manage essential internet connectivity
# ...........................................................
# 2020-04-04 gustavo.casanova@gmail.com

FIREWALL_VM="HTA-Firewall"
FIREWALL_HERE=0
INTERNET_TARGET="8.8.8.8"
FIREWALL_TARGET="10.6.17.1"
INTERNET_REACHED=0
FIREWALL_REACHED=0
INTERNET_PING_RETRIES=30
FIREWALL_PING_RETRIES=30
PING_TIMEOUT=2
PHYSICAL_1=10.6.17.30
PHYSICAL_2=10.6.17.40
PHYSICALS_ACTIVE=0

# Detect on which physical server is this script running
THIS_PHYSICAL=$(sudo hostname -s | tr a-z A-Z)
THIS_PHYSICAL_IP=$(sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '192.')

echo ""
echo "$(date +%F" "%T) ($THIS_PHYSICAL $THIS_PHYSICAL_IP): Starting essential network services check routine ..."

echo ""
echo "$(date +%F" "%T) ($THIS_PHYSICAL $THIS_PHYSICAL_IP): Checking active physical servers ..."
echo ""

# Determine how many physical servers are up and running beside this one
for PHYSICAL in $PHYSICAL_1 $PHYSICAL_2; do
    echo -n "physical server "
    if [ $PHYSICAL == "$THIS_PHYSICAL_IP" ]; then
        echo "$PHYSICAL ($THIS_PHYSICAL) This is me!"
    else
        echo -n "$PHYSICAL "
        if ping -c 1 -w $PING_TIMEOUT $PHYSICAL &>/dev/null; then
            PHYSICALS_ACTIVE=$((PHYSICALS_ACTIVE + 1))
            echo "active!"
        else
            echo "inactive ..."
        fi
    fi
done

echo ""
echo "$(date +%F" "%T) ($THIS_PHYSICAL $THIS_PHYSICAL_IP): Pinging network targets ..."
echo ""

# Are basic internet services running on this machine?
if [ "$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$FIREWALL_VM$")" ]; then
    FIREWALL_HERE=1
fi

# Check whether a well-known internet target is reachable
echo -n "Internet target ($INTERNET_TARGET) -> "
while [ "$INTERNET_PING_RETRIES" -gt 0 ]; do
    if ping -c 1 -w $PING_TIMEOUT $INTERNET_TARGET &>/dev/null; then
        echo -n ". "
        INTERNET_REACHED=1
    else
        echo -n "x "
    fi
    INTERNET_PING_RETRIES=$((INTERNET_PING_RETRIES - 1))
done
echo ""

# Check whether the local firewall is reachable on LAN
if [ $INTERNET_REACHED != 1 ]; then
    echo ""
    echo -n "Firewall on LAN ($FIREWALL_TARGET) -> "
    while [ "$FIREWALL_PING_RETRIES" -gt 0 ]; do
        if ping -c 1 -w $PING_TIMEOUT $FIREWALL_TARGET &>/dev/null; then
            echo -n ". "
            FIREWALL_REACHED=1
        else
            echo -n "x "
        fi
        FIREWALL_PING_RETRIES=$((FIREWALL_PING_RETRIES - 1))
    done
    echo ""
fi

# Decision-making routine for handling network services
if [ $INTERNET_REACHED = 1 ]; then
    echo ""
    echo "$(date +%F" "%T) ($THIS_PHYSICAL): Internet target reached, check succeeded, finishing ..."
    echo ""

    # echo "Checking that there is only one firewall VM running across the physical servers ..."
    # for ESSENTIAL_SERVICE in $(cat ~/EssentialNetServices); do
    #     echo -n $ESSENTIAL_SERVICE;
    #     if [ $THIS == $ESSENTIAL_SERVICE ]; then
    #         echo " It's here";
    #     else
    #         echo "";
    #     fi
    # done
    # for PHYSICAL in $PHYSICAL_1 $PHYSICAL_2; do
    #     echo -n "physical server "
    #     if [ $PHYSICAL == "$THIS_PHYSICAL_IP" ]; then
    #     if [[ ! -z $(ssh netbackup@$PHYSICAL ~/itops-scripts/bare-metal/vboxrunning.sh | grep $VM) ]]; then
    #         echo  "YEAH";
    #     else
    #         echo "NO!";
    #     fi
    # done

else
    echo ""
    echo "$(date +%F" "%T) ($THIS_PHYSICAL): Internet target NOT reached, checking the firewall LAN interface ..."
    if [ $FIREWALL_REACHED = 1 ]; then
        echo ""
        echo "$(date +%F" "%T) ($THIS_PHYSICAL): The firewall appears active on LAN, maybe there is a momentary internet connection break-up, finishing ..."
        echo ""
    else
        echo ""
        echo "$(date +%F" "%T) ($THIS_PHYSICAL): The Firewall does NOT reply to ping on local LAN, checking whether is running on this machine ..."
        sleep 1
        if [ $FIREWALL_HERE = 1 ]; then
            echo ""
            echo "$(date +%F" "%T) ($THIS_PHYSICAL): $FIREWALL_VM is running on this machine but it does not respond to ping on LAN, maybe there is a local VirtualBox hypervisor failure ..."
            sleep 1

            echo ""
            if [ $PHYSICALS_ACTIVE -ge 1 ]; then
                echo "$(date +%F" "%T) ($THIS_PHYSICAL): Stopping Firewall and OpenVPN in the hope that another machine takes over the services ..."
                sleep 1
                ~/itops-scripts/physical-machines/internet-off.sh
                # --- ~/itops-scripts/physical-machines/vm-off.sh $FIREWALL_VM
                echo "$(date +%F" "%T) ($THIS_PHYSICAL): Firewall and OpenVPN should be stopped by now, finishing ..."
            else
                echo "$(date +%F" "%T) ($THIS_PHYSICAL): There are no other physical machines active!"
                echo ""
                echo "$(date +%F" "%T) ($THIS_PHYSICAL): Stopping all services and attempting a server last-resort reboot, Bye!"
                sleep 1
            ~/itops-scripts/physical-machines/stop-and-reboot.sh
            fi     
        else
            echo ""
            echo "$(date +%F" "%T) ($THIS_PHYSICAL): Firewall NOT present on LAN nor is running on this machine, starting internet services on this machine!"
            sleep 1
            ~/itops-scripts/physical-machines/internet-on.sh
            # --- ~/itops-scripts/physical-machines/vm-on.sh $FIREWALL_VM
        fi
    fi
fi
echo ""
echo "@@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@"
echo ""

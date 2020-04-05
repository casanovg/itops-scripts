#!/bin/sh

# ****************************************************************
# * Script to check and manage basic essential internet services *
# * ============================================================ *
# * 2020-04-04 Gustavo Casanova                                  *
# * gcasanova@hellermanntyton.com.ar                             *
# ****************************************************************

FIREWALL_VM="HTA-Firewall"
FIREWALL_HERE=0
INTERNET_TARGET="8.8.8.8"
FIREWALL_TARGET="10.6.17.1"
INTERNET_REACHED=0
FIREWALL_REACHED=0
INTERNET_PING_RETRIES=30
FIREWALL_PING_RETRIES=30
PING_TIMEOUT=2
BARE_METAL_1=10.6.17.30
BARE_METAL_2=10.6.17.40
BARE_METAL_3=10.6.17.50
BARE_METALS_ACTIVE=0
THIS_BARE_METAL=$(sudo hostname -s | tr a-z A-Z)
THIS_BARE_METAL_IP=$(sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '192.')

echo ""
echo "$(date +%F" "%T) ($THIS_BARE_METAL $THIS_BARE_METAL_IP): Starting essential network services check routine ..."

echo ""
echo "$(date +%F" "%T) ($THIS_BARE_METAL $THIS_BARE_METAL_IP): Checking active bare-metal servers ..."
echo ""

for BARE_METAL in $BARE_METAL_1 $BARE_METAL_2 $BARE_METAL_3; do
    echo -n "Bare-metal server "
    if [ $BARE_METAL == "$THIS_BARE_METAL_IP" ]; then
        echo "$BARE_METAL ($THIS_BARE_METAL) This is me!"
    else
        echo -n "$BARE_METAL "
        if ping -c 1 -w $PING_TIMEOUT $BARE_METAL &>/dev/null; then
            BARE_METALS_ACTIVE=$((BARE_METALS_ACTIVE + 1))
            echo "active!"
        else
            echo "inactive ..."
        fi
    fi
done

echo ""
echo "$(date +%F" "%T) ($THIS_BARE_METAL $THIS_BARE_METAL_IP): Pinging network targets ..."
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
    echo "$(date +%F" "%T) ($THIS_BARE_METAL): Internet target reached, check succeeded, finishing ..."
    echo ""
else
    echo ""
    echo "$(date +%F" "%T) ($THIS_BARE_METAL): Internet target NOT reached, checking the firewall LAN interface ..."
    if [ $FIREWALL_REACHED = 1 ]; then
        echo ""
        echo "$(date +%F" "%T) ($THIS_BARE_METAL): The firewall appears active on LAN, maybe there is a momentary internet connection break-up, finishing ..."
        echo ""
    else
        echo ""
        echo "$(date +%F" "%T) ($THIS_BARE_METAL): The Firewall does NOT reply to ping on local LAN, checking whether is running on this machine ..."
        sleep 1
        if [ $FIREWALL_HERE = 1 ]; then
            echo ""
            echo "$(date +%F" "%T) ($THIS_BARE_METAL): $FIREWALL_VM is running on this machine but it does not respond to ping on LAN, maybe there is a local VirtualBox hypervisor failure ..."
            sleep 1

            echo ""
            if [ $BARE_METALS_ACTIVE -ge 1 ]; then
                echo "$(date +%F" "%T) ($THIS_BARE_METAL): Stopping Firewall and OpenVPN in the hope that another machine takes over the services ..."
                sleep 1
                ~/itops-scripts/bare-metal/internet-off.sh
                # --- ~/itops-scripts/bare-metal/vm-off.sh $FIREWALL_VM
                echo "$(date +%F" "%T) ($THIS_BARE_METAL): Firewall and OpenVPN should be stopped by now, finishing ..."
            else
                echo "$(date +%F" "%T) ($THIS_BARE_METAL): There are no other bare-metal machines active!"
                echo ""
                echo "$(date +%F" "%T) ($THIS_BARE_METAL): Stopping all services and attempting a server last-resort reboot, Bye!"
                sleep 1
            ~/itops-scripts/bare-metal/stop-and-reboot.sh
            fi     
        else
            echo ""
            echo "$(date +%F" "%T) ($THIS_BARE_METAL): Firewall NOT present on LAN, starting internet services on this machine!"
            sleep 1
            ~/itops-scripts/bare-metal/internet-on.sh
            # --- ~/itops-scripts/bare-metal/vm-on.sh $FIREWALL_VM
        fi
    fi
fi
echo ""
echo "@@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@"
echo ""

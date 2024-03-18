#!/bin/sh

# Script to restart a worker vm if it has no internet access
# ...........................................................
# 2024-03-18 gustavo.casanova@gmail.com

INTERNET_TARGET="8.8.8.8"
FIREWALL_TARGET="10.17.17.254"
INTERNET_REACHED=0
FIREWALL_REACHED=0
INTERNET_PING_RETRIES=30
FIREWALL_PING_RETRIES=30
PING_TIMEOUT=2

echo "$(date +%F" "%T) ($THIS_PHYSICAL $THIS_PHYSICAL_IP): Checking internet connectivity ..."

echo ""
echo "$(date +%F" "%T) ($THIS_PHYSICAL $THIS_PHYSICAL_IP): Pinging network targets ..."
echo ""

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

else
    echo ""
    echo "$(date +%F" "%T) ($THIS_PHYSICAL): Internet target NOT reached, checking the firewall LAN interface ..."
    if [ $FIREWALL_REACHED = 1 ]; then
        echo ""
        echo "$(date +%F" "%T) ($THIS_PHYSICAL): The firewall appears active on LAN, maybe there is a momentary internet connection break-up, finishing ..."
        echo ""
    else
        echo ""
        echo "$(date +%F" "%T) ($THIS_PHYSICAL): The Firewall does NOT reply to ping on local LAN, rebooting this machine ..."
	sudo bash -c 'HOST_NAME="$(hostname -s)"; echo "" > /dev/tty1; echo "" > /dev/tty1; cowsay "$(echo ${HOST_NAME^^} rebooting!; echo ""; date +%F" "%R)" > /dev/tty1; echo "" > /dev/tty1'
	sudo shutdown -r
    fi
fi
echo ""
echo "@@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@"
echo ""


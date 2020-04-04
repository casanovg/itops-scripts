# FIREWALL_VM="HTA-Firewall"
# OPENVPN_VM="HTA-NetPal"

FIREWALL_VM="HTA-Cloud"
# OPENVPN_VM="NB-Hibou"
FIREWALL_HERE=0
# OPENVPN_HERE=0
INTERNET_TARGET="8.8.8.6"
FIREWALL_TARGET="10.6.17.86"
INTERNET_REACHED=0
FIREWALL_REACHED=0
INTERNET_PING_RETRIES=5
FIREWALL_PING_RETRIES=5
PING_TIMEOUT=2
PING_RESULT=0

echo ""
echo "$(date -I --date='now'): Pinging network targets ..."
echo ""

# Are basic internet services running on this machine?
# echo ""
# echo "Checking whether the firewall VM is running on this machine ..."
# echo ""
if [ "$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$FIREWALL_VM$")" ]; then
    FIREWALL_HERE=1
    # echo "Firewall running here ..."
#else
    # echo "Firewall NOT running here ..."
fi

# Check whether a well-known internet target is reachable
# echo ""
# echo "Checking whether a well-known internet target ($INTERNET_TARGET) is reachable ..."
# echo ""
echo -n "Internet: "
while [ "$INTERNET_PING_RETRIES" -gt 0 ]; do
    if ping -c 1 -w $PING_TIMEOUT $INTERNET_TARGET &>/dev/null; then
        echo -n ". "
        INTERNET_REACHED=1
    else
        echo -n "x "
    fi
    INTERNET_PING_RETRIES=$((INTERNET_PING_RETRIES-1))
done
echo ""

# Check whether the local firewall is reachable
# echo ""
# echo "Checking whether the local firewall ($FIREWALL_TARGET) is reachable ..."
# echo ""
echo -n "LAN target: "
while [ "$FIREWALL_PING_RETRIES" -gt 0 ]; do
    if ping -c 1 -w $PING_TIMEOUT $FIREWALL_TARGET &>/dev/null; then
        echo -n ". "
        FIREWALL_REACHED=1
    else
        echo -n "x "
    fi
    FIREWALL_PING_RETRIES=$((FIREWALL_PING_RETRIES-1))
done
echo ""


if [ $INTERNET_REACHED == 1 ]; then
    echo ""
    echo "$(date -I --date='now'): Internet target reached, it is all right, finishing ..."
    exit 0
else
    echo ""
    echo "$(date -I --date='now'): Internet target NOT reached, checking the firewall LAN interface ..."
    if [ $FIREWALL_REACHED == 1 ]; then
        echo ""
        echo "$(date -I --date='now'): The firewall appears active on local LAN, maybe there is a temporal internet failure, finishing ..."
        exit 1

    else
        echo ""
        echo "$(date -I --date='now'): The Firewall does NOT reply to ping on local LAN, checking whether is running on this machine ..."
        if [ $FIREWALL_HERE == 1 ]; then
            echo ""
            echo "$(date -I --date='now'): $FIREWALL_VM is running on this machine ($(hostname -s)) but it does not respond"
            echo "to ping on LAN, maybe there is a local VirtualBox hypervisor failure ..."
            echo ""
            echo "$(date -I --date='now'): Stopping Firewall and OpenVPN in the hope that another machine takes over the services ..."
            # ~/itops-scripts/bare-metal/internet-off.sh
        else
            echo ""
            echo "$(date -I --date='now'): $FIREWALL_VM NOT present on LAN, starting internet services on this machine ($(hostname -s))!"
            # ~/itops-scripts/bare-metal/internet-on.sh
        fi        
    fi
fi

echo ""

# declare -i TARGETS=0
# declare -i NO_ANS=0
# declare -i SEC=0
# declare -i MIN=0

# INTERNET_TARGET_1="10.6.17.36"
# LOCAL_TARGET_1="10.6.17.1"

# echo ""
# for TGT in $INTERNET_TARGET_1 2 3 "10.6.17.37" 5; do
#   TARGETS=TARGETS+1
#   echo "Target $TARGETS -->" $TGT
# done

# echo
# echo "Targets to test: $TARGETS"
# echo ""

# # Check internet
# for TGT in $INTERNET_TARGET_1 2 3 10.6.17.37 5; do
#   while ! ping -c1 -w2 "$TGT" &>/dev/null; do

#     echo "Total downtime: " $MIN:$SEC

#     echo ""
#     if [ $MIN == 0 ] && [ $SEC == 10 ]; then
#       echo "  WOW! Target $TGT failed ..."
#       NO_ANS=NO_ANS+1
#       break
#     fi
#     echo ""

#     sleep 10

#     SEC=SEC+10

#     if [ $SEC == 60 ]; then
#       SEC=0
#       MIN=MIN+1
#     fi

#   done
# done

# echo " Hosts no aswering: $NO_ANS ..."

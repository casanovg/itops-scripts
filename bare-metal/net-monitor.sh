# FIREWALL_VM="HTA-Firewall"
# OPENVPN_VM="HTA-NetPal"

FIREWALL_VM="HTA-Cloud"
OPENVPN_VM="NB-Hibou"
FIREWALL_HERE=0
OPENVPN_HERE=0
INTERNET_TARGET="8.8.8.6"
FIREWALL_TARGET="10.6.17.86"
INTERNET_REACHED=0
FIREWALL_REACHED=0
INTERNET_PING_RETRIES=5
FIREWALL_PING_RETRIES=5
PING_TIMEOUT=2
PING_RESULT=0

# Are basic internet services running on this machine?
echo ""
echo "Checking whether the firewall VM is running on this machine ..."
echo ""
if [ "$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$FIREWALL_VM$")" ]; then
    FIREWALL_HERE=1
    echo "Firewall running here ..."
else
    echo "Firewall NOT running here ..."
fi

echo ""
echo "Checking whether the OpenVPN VM is running on this machine ..."
echo ""
if [ "$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$OPENVPN_VM$")" ]; then
    OPENVPN_HERE=1
    echo "OpenVPN running here ..."
else
    echo "OpenVPN NOT running here ..."
fi

# Check whether a well-known internet target is reachable
echo ""
echo "Checking whether a well-known internet target ($INTERNET_TARGET) is reachable ..."
echo ""
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
echo ""
echo "Checking whether the local firewall ($FIREWALL_TARGET) is reachable ..."
echo ""
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
    echo "Internet target reached, nothing left to do, exiting now ..."
    exit 0
else
    echo ""
    echo "Internet target NOT reached, checking the local firewall LAN interface ..."
    if [ $FIREWALL_REACHED == 1 ]; then
        echo ""
        echo "The firewall appears active on local LAN, maybe there is a temporal internet failure, exiting ..."
        exit 1

    else
        echo ""
        echo "The Firewall does NOT reply to ping on local LAN, checking whether is running on this machine ..."
        if [ $FIREWALL_HERE == 1 ]; then
            echo ""
            echo "$FIREWALL_VM running on this machine ($(hostname -s)) but it does not respond"
            echo "to ping, maybe there is a local VirtualBox hypervisor failure ..."
            echo ""
            echo "Stopping Firewall VM in the hope that another server takes over the service ..."
            # ~/itops-scripts/bare-metal/vm-off $FIREWALL_VM
            if [ $OPENVPN_HERE == 1 ]; then
                echo ""
                echo "$OPENVPN_VM running on this machine ($(hostname -s)), stopping it..."
            # ~/itops-scripts/bare-metal/vm-off $OPENVPN_VM                
            fi

        else
            echo ""
            echo "$FIREWALL_VM NOT present on LAN, starting it on this machine ($(hostname -s))!"
            # ~/itops-scripts/bare-metal/vm-on $FIREWALL_VM
            if [ $OPENVPN_HERE == 1 ]; then
                echo ""
                echo "$OPENVPN_VM running on this machine ($(hostname -s)), leaving it ..."
            else
                echo ""
                echo "$OPENVPN_VM NOT running on this machine ($(hostname -s)), starting it!..."
                # ~/itops-scripts/bare-metal/vm-on $OPENVPN_VM
            fi            
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

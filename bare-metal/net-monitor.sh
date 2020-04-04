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
if [ $(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$FIREWALL_VM$") ]; then
    FIREWALL_HERE=1
    echo "Firewall found ..."
else
    echo "Firewall NOT found ..."
fi

echo ""
echo "Checking whether the OpenVPN VM is running on this machine ..."
echo ""
if [ $(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$OPENVPN_VM$") ]; then
    OPENVPN_HERE=1
    echo "OpenVPN found ..."
else
    echo "openVPN NOT found ..."
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

echo ""
if [ $INTERNET_REACHED == 1 ]; then
    echo "Internet target reached: "$INTERNET_REACHED
else
    echo "Internet target NOT reached: "$INTERNET_REACHED
fi

echo ""
if [ $FIREWALL_REACHED == 1 ]; then
    echo "Firewall reached: "$FIREWALL_REACHED
else
    echo "Firewall NOT reached: "$FIREWALL_REACHED
fi

echo ""
if [ $FIREWALL_HERE == 1 ]; then
    echo "$FIREWALL_VM running on this machine ($(hostname -s))..."
else
    echo "$FIREWALL_VM NOT running on this machine ($(hostname -s))..."
fi

echo ""
if [ $OPENVPN_HERE == 1 ]; then
    echo "$OPENVPN_VM running on this machine ($(hostname -s))..."
else
    echo "$OPENVPN_VM NOT running on this machine ($(hostname -s))..."
fi
echo ""

#echo "Unable to reach a well-known internet target, checking whether the local firewall replies ..."
#echo "Firewall VM running but it does not respond to ping, maybe there is a local VirtualBox hypervisor problem ..."


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

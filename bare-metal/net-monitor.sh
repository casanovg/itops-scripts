# FIREWALL_VM="HTA-Firewall"
# OPENVPN_VM="HTA-NetPal"

FIREWALL_VM="HTA-Cloud"
OPENVPN_VM="NB-Hibou"
FIREWALL_HERE=0
OPENVPN_HERE=0
INTERNET_TARGET="8.8.8.8"
INTERNET_REACHED=0
PING_RETRIES=5
PING_TIMEOUT=2
PING_RESULT=0

# Are basic internet services running on this machine?
echo ""
if [ $(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$FIREWALL_VM$") ]; then
    echo "$FIREWALL_VM running on this machine ($(hostname -s))..."
    FIREWALL_HERE=1
else
    echo "$FIREWALL_VM NOT running on this machine ($(hostname -s))..."
fi

if [ $(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$OPENVPN_VM$") ]; then
    echo "$OPENVPN_VM running on this machine ($(hostname -s))..."
    OPENVPN_HERE=1
else
    echo "$OPENVPN_VM NOT running on this machine ($(hostname -s))..."
fi
echo ""

# Check whether a well-known internet target is reachable
#PING_RESULT=$(ping -c$PING_RETRIES -w$PING_TIMEOUT $INTERNET_TARGET)
#ping -c$PING_RETRIES -w$PING_TIMEOUT $INTERNET_TARGET
#PING_RESULT=$?
#echo "PR: $PING_RESULT"
#if [ $PING_RESULT != 0 ]; then
while [ "$PING_RETRIES" -gt 0 ]; do
    if ping -c 1 -w $PING_TIMEOUT $INTERNET_TARGET &>/dev/null; then
        echo -n ". "
        INTERNET_REACHED=1
    else
        echo -n "x "
    fi
    PING_RETRIES=$((PING_RETRIES-1))
done
echo ""
echo ""
echo "Al final: "$INTERNET_REACHED
echo ""




# declare -i TARGETS=0
# declare -i NO_ANS=0
# declare -i SEC=0
# declare -i MIN=0
# declare -i JOT=0

# INTERNET_TARGET_1="10.6.17.36"
# LOCAL_TARGET_1="10.6.17.1"
# LOCAL_TARGET_2="10.6.17.41"

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

# FIREWALL_VM="HTA-Firewall"
# OPENVPN_VM="HTA-NetPal"

FIREWALL_VM="HTA-Cloud"
OPENVPN_VM="NB-Hibou"

# Am I running the internet basic services?
FIREWALL_RUNNING=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$FIREWALL_VM$")
OPENVPN_RUNNING=$(vboxmanage list runningvms | gawk -F\" '{print $(NF-1)}' | grep -w "^$OPENVPN_VM$")

echo ""
if [ $FIREWALL_RUNNING ]; then
    echo "Firewall: "$FIREWALL_RUNNING" running on this machine ($(hostname -s))..."
else
    echo "Firewall: "$FIREWALL_VM" NOT running on this machine ($(hostname -s))..."
fi

if [ $OPENVPN_RUNNING ]; then
    echo " OpenVPN: "$OPENVPN_RUNNING" running on this machine ($(hostname -s))..."
else
    echo " OpenVPN: "$OPENVPN_VM" NOT running on this machine ($(hostname -s))..."
fi
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

# FIREWALL_VM="HTA-Firewall"
# OPENVPN_VM="HTA-NetPal"

FIREWALL_VM="NB-Hibou"
FIREWALL_HERE=0
INTERNET_TARGET="8.8.8.6"
FIREWALL_TARGET="10.6.17.86"
INTERNET_REACHED=0
FIREWALL_REACHED=0
INTERNET_PING_RETRIES=5
FIREWALL_PING_RETRIES=5
PING_TIMEOUT=2
BARE_METAL_1=10.6.17.30
BARE_METAL_2=10.6.17.40
BARE_METAL_3=10.6.17.50
BARE_METALS_ACTIVE=0
THIS_BARE_METAL=$(hostname -s | tr a-z A-Z)
THIS_BARE_METAL_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v '192.')

echo ""
echo "$(date +%F" "%T) ($THIS_BARE_METAL $THIS_BARE_METAL_IP): Starting essential network services check routine ..."

echo ""
echo "$(date +%F" "%T) ($THIS_BARE_METAL $THIS_BARE_METAL_IP): Checking active bare-metal servers ..."
echo ""

for BARE_METAL in $BARE_METAL_1 $BARE_METAL_2 $BARE_METAL_3; do
    echo -n "Bare-metal server "
    if [ $BARE_METAL == $THIS_BARE_METAL_IP ]; then
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
echo "Other bare-metal servers active: $BARE_METALS_ACTIVE"

echo ""
echo "$(date +%F" "%T) ($THIS_BARE_METAL $THIS_BARE_METAL_IP): Pinging network targets ..."
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
echo -n "Internet target -> "
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

# Check whether the local firewall is reachable
# echo ""
# echo "Checking whether the local firewall ($FIREWALL_TARGET) is reachable ..."
echo ""
echo -n "Firewall on LAN -> "
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

if [ $INTERNET_REACHED == 1 ]; then
    echo ""
    echo "$(date +%F" "%T) ($THIS_BARE_METAL): Internet target reached, it is all right, finishing ..."
    echo ""
    exit 0
else
    echo ""
    echo "$(date +%F" "%T) ($THIS_BARE_METAL): Internet target NOT reached, checking the firewall LAN interface ..."
    if [ $FIREWALL_REACHED == 1 ]; then
        echo ""
        echo "$(date +%F" "%T) ($THIS_BARE_METAL): The firewall appears active on local LAN, maybe there is a temporal internet failure, finishing ..."
        echo ""
        exit 1
    else
        echo ""
        echo "$(date +%F" "%T) ($THIS_BARE_METAL): The Firewall does NOT reply to ping on local LAN, checking whether is running on this machine ..."
        sleep 1
        if [ $FIREWALL_HERE == 1 ]; then
            echo ""
            echo "$(date +%F" "%T) ($THIS_BARE_METAL): $FIREWALL_VM is running on this machine but it does not respond to ping"
            echo "                                      on LAN, maybe there is a local VirtualBox hypervisor failure ..."
            sleep 1

            echo ""
            if [ $BARE_METALS_ACTIVE -ge 1 ]; then
                echo "$(date +%F" "%T) ($THIS_BARE_METAL): Stopping Firewall and OpenVPN in the hope that another machine takes over the services ..."
                sleep 1
                # ~/itops-scripts/bare-metal/internet-off.sh
                ~/itops-scripts/bare-metal/vm-off.sh $FIREWALL_VM
            else
                echo "$(date +%F" "%T) ($THIS_BARE_METAL): There are no other bare-metal machines active!"
                echo ""
                echo "$(date +%F" "%T) ($THIS_BARE_METAL): Attempting a last-resource server reboot ..."
                sleep 1
            # ~/itops-scripts/bare-metal/stop-and-reboot.sh
            fi

            echo "$(date +%F" "%T) ($THIS_BARE_METAL): Firewall and OpenVPN should be stopped by now, finishing ..."
        else
            echo ""
            echo "$(date +%F" "%T) ($THIS_BARE_METAL): Firewall NOT present on LAN, starting internet services on this machine!"
            sleep 1
            # ~/itops-scripts/bare-metal/internet-on.sh
            ~/itops-scripts/bare-metal/vm-on.sh $FIREWALL_VM
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

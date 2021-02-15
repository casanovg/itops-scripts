#!/bin/sh

# Script to update Cloudflare dynamic
# DNS record for OpenWRT
# .............................................
# 2021-02-12 gustavo.casanova@gmail.com

source ~/.cloudflare-settings

# Please set the following variables om a separate
# ".cloudflare-settings" file before running this script:
#
#    API_URL="https://api.cloudflare.com/client/v4"
#    EMAIL="your_email@domain.com"
#    GLOBAL_API_KEY="8c54527cb55224245643a2ca7cbd32b4bb990"
#    ACCOUNT_ID="876bca901223ded91fdffa281390bb31"
#    ZONE_ID="3ef7db67ae12dd63f0998ae8e8e97a9a"
#    ZONE_NAME="domain.com"
#    RECORD_ID="9ab3490fdda901255bb332a12cc127fa"
#    RECORD_TYPE="A"
#    RECORD_NAME="service.domain.com"
#    RECORD_TTL="1"
#    RECORD_PROXY="true"
#    MATCH="all"

# Choose any of these services URL
# to get my external IP address:
#
#    checkip.amazonaws.com
#    ifconfig.me
#    icanhazip.com
#    ipecho.net/plain
#    ifconfig.co

MY_IP_URL="checkip.amazonaws.com"

CF_IP="0.0.0.0"

CF_PROXIED=""

LOG_PATH="/var/log/cloudflare-updates.log"

# Function to check IPv4 syntax
validate_ip () {
    if expr "$1" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' > /dev/null; then
        for i in 1 2 3 4; do
            if [ $(echo "$1" | cut -d. -f$i) -gt 255 ]; then
                # echo " > Invalid IP address: \"$1\""
                return 1
            fi
        done
        # echo " > Valid IP address: \"$1\""
        return 0
    else
        # echo " > Invalid IP address: \"$1\""
        return 1
    fi
}

# Function to get the Cloudflare DNS record info
get_cf_dns () {

    # Get Cloudflare DNS record IP address
    CF_IP=$(curl -s -X GET "$API_URL/zones/$ZONE_ID/dns_records?name=$RECORD_NAME&match=$MATCH" \
                 -H "Content-Type: application/json" \
                 -H "X-Auth-Key: $GLOBAL_API_KEY" \
                 -H "X-Auth-Email: $EMAIL" | sed -e 's/[{}]/''/g' |
            awk -v RS=',"' -F: '/^content/ {print $2}' |
            tr -d '"')

    # Get Cloudflare DNS record proxy status
    CF_PROXIED=$(curl -s -X GET "$API_URL/zones/$ZONE_ID/dns_records?name=$RECORD_NAME&match=$MATCH" \
                 -H "Content-Type: application/json" \
                 -H "X-Auth-Key: $GLOBAL_API_KEY" \
                 -H "X-Auth-Email: $EMAIL" | sed -e 's/[{}]/''/g' |
            awk -v RS=',"' -F: '/^proxied/ {print $2}' |
            tr -d '"')

}

# Function to update the Cloudflare DNS record data
update_cf_dns () {

    # Update record IP address
    RESULT=$(curl -s -X PUT "$API_URL/zones/$ZONE_ID/dns_records/$RECORD_ID" \
                  -H "X-Auth-Key: $GLOBAL_API_KEY" \
                  -H "X-Auth-Email: $EMAIL" \
                  -H "Content-Type: application/json" \
                  --data '{"type":'\"$RECORD_TYPE\"',"name":'\"$RECORD_NAME\"',"content":'\"$1\"',"ttl":'$RECORD_TTL',"proxied":'$RECORD_PROXY'}' |
             grep "\"success\":true")
    if [ ! -z $RESULT ]; then
        echo | tee -a $LOG_PATH
        echo -n " " | tee -a $LOG_PATH
        echo -n "DNS record successfully updated to $1 " | tee -a $LOG_PATH
        echo "on $(date)!" >> $LOG_PATH
        echo
    else
        echo | tee -a $LOG_PATH
        echo -n " " | tee -a $LOG_PATH
        echo -n "Clouflare record update to $1 failed " | tee -a $LOG_PATH
        echo "on $(date)!" >> $LOG_PATH
        echo
    fi

}

echo ".........................................................................."
echo " Checking Dynamic DNS on $(date +"%Y-%m-%d %H:%M:%S")"

# Get my external IP address
MY_IP="$(curl -s $MY_IP_URL 2>>/dev/null)"

# Validate the external IP address
if $(validate_ip $MY_IP); then
    echo
    echo " Device current external IP address: $MY_IP"
else
    echo
    echo " Unable to get my external IP address in a valid format. Exiting!"
    echo ".........................................................................."
    echo
    exit
fi

# Get DNS name resolution for the dynamic IP
DNS_LOOKUP=$(nslookup $RECORD_NAME | grep 'Address*' | grep -v 'localhost' | awk '{print $3}')

# Validate the DNS lookup IP address
if $(validate_ip $DNS_LOOKUP); then
    echo " DNS lookup for $RECORD_NAME: $DNS_LOOKUP"
else
    echo
    echo " Unable to get a valid DNS lookup for $RECORD_NAME ..."
fi

# Comparing my external IP address with the DNS lookup
if [ "$MY_IP" != "$DNS_LOOKUP" ]; then

    echo
    echo " The DNS lookup of the dynamic IP doesn't match the current"
    echo " external IP address. Verifying the Cloudflare DNS record ..."

    # Call the get Cloudflare record info function
    get_cf_dns
    #echo

    # Validate the Cloudflare DNS record IP address
    if $(validate_ip $CF_IP); then
        echo
        echo " = Cloudflare DNS record IP for $RECORD_NAME: $CF_IP"

        # Comparing my external IP address with the Cloudflare record
        if [ "$MY_IP" != "$CF_IP" ]; then

            # Call the update Cloudflare function
            update_cf_dns $MY_IP
            echo

        else

            echo
            echo " The Cloudflare DNS record IP address matches the external IP address,"
            echo " perhaps the DNS lookup returned a different value due to a DNS zone"
            echo " propagation delay or because the record proxy setting is incorrect ..."
            echo
            echo " Checking Cloudflare DNS record proxy status ..."
            echo
            echo " = Cloudflare DNS record proxy for $RECORD_NAME: $CF_PROXIED"
            if [ "$CF_PROXIED" != "$RECORD_PROXY" ]; then
                echo
                echo " Cloudflare DNS record proxy:$CF_PROXIED, trying to set proxy:$RECORD_PROXY ..."

                # Call the update Cloudflare function
                update_cf_dns $MY_IP
            else
                echo
                echo " DNS proxy setting correct, please wait for DNS propagation. Exiting!"
            fi
            echo ".........................................................................."
            echo
            exit

        fi

    else
        echo
        echo " Unable to get a valid dynamic IP DNS record from Cloudflare "
        echo " Forcing a $RECORD_NAME record update ..."

        # Call the update Cloudflare function
        update_cf_dns $MY_IP
        echo

    fi

else

    echo
    echo " The DNS lookup of the dynamic IP matches the device current"
    echo " external IP address. DNS record update not needed. Exiting!"
    echo ".........................................................................."
    echo
    exit

fi

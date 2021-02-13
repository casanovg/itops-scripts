#/bin/sh

# Update Cloudflare Dynamic DNS record
# .............................................
# 2021-02-12 gustavo.casanova@gmail.com

source ~/.cloudflare-settings

# Please set the following variables before running this script:
#
#    API_URL="https://api.cloudflare.com/client/v4"
#    EMAIL="your_email@domain.com"
#    GLOBAL_API_KEY="8c54527cb55224245643a2ca7cbd32b4bb990"
#    ACCOUNT_ID="876bca901223ded91fdffa281390bb31"
#    ZONE_ID="3ef7db67ae12dd63f0998ae8e8e97a9a"
#    ZONE_NAME="domain.com"
#    RECORD_ID="9ab3490fdda901255bb332a12cc127fa"
#    RECORD_NAME="service.domain.com"
#    RECORD_TYPE="A"
#    MATCH="all"
#

MY_IP="$(/root/get-myip.sh)"

# API_TOKEN="P5UHT9maztaQkeRxNbpR-R-aNTcZ_PxfLFeApuwk"

# Api token test
# curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
#      -H "Authorization: Bearer P5UHT9maztaQkeRxNbpR-R-aNTcZ_PxfLFeApuwk" \
#      -H "Content-Type:application/json"

LOG_PATH="/var/log/cloudflare-updates.log"

# Get current DNS record at Cloudflare
CF_IP=$(curl -s -X GET "$API_URL/zones/$ZONE_ID/dns_records?name=$RECORD_NAME&match=$MATCH" \
             -H "Content-Type: application/json" \
             -H "X-Auth-Key: $GLOBAL_API_KEY" \
             -H "X-Auth-Email: $EMAIL" | sed -e 's/[{}]/''/g' |
        awk -v RS=',"' -F: '/^content/ {print $2}' |
        tr -d '"')

echo
echo "............................................................"
echo " Checking Dynamic DNS on $(date)"
echo "    Current IP: $MY_IP"
echo " Cloudflare IP: $CF_IP"

if [ "$MY_IP" != $CF_IP ]; then
    echo " Cloudflare DNS record outdated, trying to update it ..."
    # Update record address
    RESULT=$(curl -s -X PUT "$API_URL/zones/$ZONE_ID/dns_records/$RECORD_ID" \
                  -H "X-Auth-Key: $GLOBAL_API_KEY" \
                  -H "X-Auth-Email: $EMAIL" \
                  -H "Content-Type: application/json" \
                  --data '{"type":'\"$RECORD_TYPE\"',"name":'\"$RECORD_NAME\"',"content":'\"$MY_IP\"',"proxied":false}' |
             grep "\"success\":true")
    if [ ! -z $RESULT ]; then
        echo >> $LOG_PATH
        echo -n " " | tee -a $LOG_PATH
        echo -n "DNS record successfully updated to $MY_IP " | tee -a $LOG_PATH
        echo "on $(date)!" >> $LOG_PATH
        echo
    else
        echo >> $LOG_PATH
        echo -n " " | tee -a $LOG_PATH
        echo -n "Clouflare record update to $MY_IP failed " | tee -a $LOG_PATH
        echo "on $(date)!" >> $LOG_PATH
        echo
    fi
else
    echo " DNS record matches current IP, no update necessary!"
fi

echo "............................................................"
echo

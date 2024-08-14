#!/bin/sh

# Stop Mail Server services
# ......................................
# 2024-08-14 gustavo.casanova@gmail.com

# Stop mail server services
echo ""
for SERVICE in postfix dovecot clamd@scan spamassassin opendkim; do
    SERVICE_STATUS="$(sudo systemctl is-active $SERVICE)"
    if [ "$SERVICE_STATUS" = "active" ]; then
        echo "Stopping $SERVICE ..."
        sudo systemctl stop $SERVICE
        sleep 2
    else
        echo "Service $SERVICE already stopped ..."
    fi
done
echo ""


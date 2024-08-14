#!/bin/sh

# Start Mail Server services
# ......................................
# 2024-08-14 gustavo.casanova@gmail.com

# Start mail server services
echo ""
for SERVICE in postfix dovecot clamd@scan spamassassin opendkim fail2ban; do
    SERVICE_STATUS="$(sudo systemctl is-active $SERVICE)"
    if [ "$SERVICE_STATUS" != "active" ]; then
        echo "Starting $SERVICE ..."
        sudo systemctl start $SERVICE
        sleep 2
    else
        echo "Service $SERVICE already running ..."
    fi
done
echo ""


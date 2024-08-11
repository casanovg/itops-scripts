#!/bin/sh

# Stop Seafile & Nginx web services
# ......................................
# 2020-02-05 gustavo.casanova@gmail.com

# Stop cloud services
echo ""
for SERVICE in nginx.service seahub.service seafile.service; do
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


#!/bin/sh

#
# Stop Seafile & Nginx web services
# ...............................................................
# 2020-02-05 gcasanova@hellermanntyton.com.ar
#

# Stop cloud services
for SERVICE in nginx seahub seafile; do
    SERVICE_STATUS="$(systemctl is-active $SERVICE)"
    if [ "$SERVICE_STATUS" = "inactive" ]; then
        echo "Stopping $SERVICE ..."
        sudo systemctl stop $SERVICE
    else
        echo "Service $SERVICE already stopped ..."
    fi
    SERVICE_STATUS=""
done

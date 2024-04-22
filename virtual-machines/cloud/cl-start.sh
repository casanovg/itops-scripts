#!/bin/sh

# Start Seafile & Nginx web services
# ......................................
# 2020-02-05 gustavo.casanova@gmail.com

# Start cloud services
echo ""
for SERVICE in seafile seahub nginx; do
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


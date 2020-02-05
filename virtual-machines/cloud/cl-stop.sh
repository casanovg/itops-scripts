#!/bin/sh

#
# Stop Seafile & Nginx web services
# ...............................................................
# 2020-02-05 gcasanova@hellermanntyton.com.ar
#

# Stop cloud services
for SERVICE in nginx seahub seafile; do
    if [ $(systemctl is-active ${SERVICE}) == "inactive" ]; then
        echo "Stopping ${SERVICE} ..."
        sudo systemctl start ${SERVICE}
    else
        echo "Service ${SERVICE} already stopped ..."
    fi
done

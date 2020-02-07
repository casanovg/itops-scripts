#!/bin/sh

#
# Start Seafile & Nginx web services
# ...............................................................
# 2020-02-05 gcasanova@hellermanntyton.com.ar
#

# Start cloud services
for SERVICE in seafile seahub nginx; do
    if [ $(systemctl is-active ${SERVICE}) == "inactive" ]; then
        echo "Starting ${SERVICE} ..."
        sudo systemctl start ${SERVICE}
    else
        echo "Service ${SERVICE} already running ..."
    fi
done

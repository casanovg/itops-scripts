#!/bin/bash

#
# Update Calibre
# ..............
# 2024-06-05 gustavo.casanova@gmail.com
#

echo "Stopping calibre service..."
sudo systemctl stop calibre-server.service
echo "Updating calibre software"
sudo bash -c 'wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin'
echo "Starting calibre service"
sudo systemctl start calibre-server.service


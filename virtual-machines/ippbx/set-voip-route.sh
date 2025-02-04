#!/bin/bash

# Destination network and gateway
DEST_NET="154.0.0.0/8"
GATEWAY="10.77.77.3"
INTERFACE="enp0s3"  # Replace with the actual interface name

# Check if the route already exists
if ip route show | grep -q "$DEST_NET via $GATEWAY dev $INTERFACE"; then
  echo "Route already exists. Exiting."
  exit 0
else
  echo "Route does not exist. Adding route..."
  sudo route add -net "$DEST_NET" gw "$GATEWAY" dev "$INTERFACE"
  if [ $? -eq 0 ]; then
    echo "Route added successfully."
  else
    echo "Error adding route. Check network configuration."
    exit 1
  fi
fi

# Optionally verify the route
ip route show | grep "$DEST_NET"

exit 0


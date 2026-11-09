#!/bin/sh

# Set the falcon-sensor CID (CrowdStrike)
# ........................................
# 2023-01-17 gustavo.casanova@gmail.com

# Quick-and-Dirty installation ...
#SRC_IP=10.6.17.30
#SRC_PATH="/home/netbackup/Downloads"
#DEST_PATH="/home/netbackup/Downloads"
#SENSOR_FILE="falcon-sensor-6.47.0-14408.el8.x86_64.rpm"
#rsync -r -v --info=progress2 $SRC_IP:$SRC_PATH/$SENSOR_FILE $DEST_PATH/.

# Remove an old version:
#sudo dnf remove falcon-sensor

# Install a new version (check version filename)
#sudo dnf install $SRC_PATH/$SENSOR_FILE

# El CID vive en common/.env (gitignored, uno por host):
#   CROWDSTRIKE_CID="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX-YY"
# Nunca commitear el .env (ver .gitignore). Pedir el valor al dueño.
ENV_FILE="$(cd -- "$(dirname -- "$0")/../common" && pwd)/.env"
if [ -f "$ENV_FILE" ]; then
	# shellcheck disable=SC1090
	. "$ENV_FILE"
fi
if [ -z "${CROWDSTRIKE_CID:-}" ]; then
	echo "ERROR: CROWDSTRIKE_CID no definido. Agregalo a $ENV_FILE" >&2
	exit 1
fi

# Set HT/Aptiv CID
sudo /opt/CrowdStrike/falconctl -s --cid="$CROWDSTRIKE_CID"

# Set daemon
#sudo systemctl enable falcon-sensor.service
#sudo systemctl start falcon-sensor.service
#sudo systemctl status falcon-sensor.service

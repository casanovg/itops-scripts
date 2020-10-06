#!/bin/sh

# Serial Monitor 
# ......................................
# 2020-10-05 gustavo.casanova@gmail.com

SERIAL_BPS=57600
SERIAL_PORT=/dev/ttyUSB0

clear

if [ -f "$SERIAL_PORT" ]; then
	echo "Opening port";
else
	echo
	echo "Port $SERIAL_PORT not found";
	echo
#	exit 1;
fi

echo
echo "Serial monitor starting at $SERIAL_BPS on port $SERIAL_PORT ..."
echo

stty ospeed $SERIAL_BPS ispeed $SERIAL_BPS -F $SERIAL_PORT
cat $SERIAL_PORT


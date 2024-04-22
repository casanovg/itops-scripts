#!/bin/sh

# Serial Monitor 
# ......................................
# 2020-10-05 gustavo.casanova@gmail.com

SERIAL_BPS=57600
SERIAL_PORT=/dev/ttyUSB0

clear

if [ ! -z "$(ls -l $SERIAL_PORT 2>>/dev/null)" ]; then
	echo
	echo "Serial monitor starting at $SERIAL_BPS on port $SERIAL_PORT ..."
	echo
else
	echo
	echo "Port $SERIAL_PORT not found";
	echo
	exit 1;
fi

stty ospeed $SERIAL_BPS ispeed $SERIAL_BPS raw -F $SERIAL_PORT
cat $SERIAL_PORT


#!/bin/bash

# Rotate

DELAY=1

while true
do
	echo -n "|"; sleep $DELAY; echo -e -n "\b \b"
	echo -n "/"; sleep $DELAY; echo -e -n "\b \b"
	echo -n "-"; sleep $DELAY; echo -e -n "\b \b"
	echo -n "\\"; sleep $DELAY; echo -e -n "\b \b"
done


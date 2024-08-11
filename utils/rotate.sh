#!/bin/bash

# Rotating bar
# ......................................
# 2021-02-14 gustavo.casanova@gmail.com

DELAY=1

while true
do
	echo -n "|"; sleep $DELAY; echo -e -n "\b \b"
	echo -n "/"; sleep $DELAY; echo -e -n "\b \b"
	echo -n "-"; sleep $DELAY; echo -e -n "\b \b"
	echo -n "\\"; sleep $DELAY; echo -e -n "\b \b"
done


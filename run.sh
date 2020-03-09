#!/bin/bash

set -ex

if [ "$#" -lt 5 ] ; then
	echo "Usage: $0 <u-boot dir> <board> <port> <tty> <prompt>"
	exit 1
fi

UBOOT=$1
BOARD=$2
PORT=$3
TTY=$4
PROMPT=$5

sh /opt/lab-tools/amaz.sh -a off -p $PORT
sleep 1

sh /opt/lab-tools/amaz.sh -a on -p $PORT
sleep 1

/opt/pyamlboot/boot.py --board-files $UBOOT $BOARD

python3 dump.py /dev/$TTY "$PROMPT"

sh /opt/lab-tools/amaz.sh -a off -p $PORT

exit 0

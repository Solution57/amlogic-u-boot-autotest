#!/bin/bash

set -ex

if [ "$#" -lt 6 ] ; then
	echo "Usage: $0 <u-boot dir> <board> <port> <tty> <prompt>"
	exit 1
fi

UBOOT=$1
BOARD=$2
PORT=$3
TTY=$4
PROMPT=$5

stty -F /dev/$TTY 115200 cs8 parenb

sh /opt/lab-tools/amaz.sh -a off -p $PORT
sleep 1
sh /opt/lab-tools/amaz.sh -a on -p $PORT
sleep 1

/opt/pyamlboot/boot.py --board-files $UBOOT $BOARD

N=0
while read -ra bytes
do
  echo "$N> $bytes"
  N=`expr $N + 1`
  if echo $bytes | grep $PROMPT ; then
	break
  fi
done < /dev/$TTY

sh /opt/lab-tools/amaz.sh -a off -p $PORT

exit 0

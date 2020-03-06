#!/bin/bash

set -ex

if [ "$#" -lt 6 ] ; then
	echo "Usage: $0 <u-boot.bin> <board> <port> <tty> <prompt>"
	exit 1
fi

UBOOT=$1
BOARD=$2
PORT=$3
TTY=$4
PROMPT=5

echo $UBOOT $BOARD $PORT $TTY $PROMPT

exit 0

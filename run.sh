#!/bin/bash

set -ex

if [ "$#" -lt 6 ] ; then
	echo "Usage: $0 <u-boot.bin> <board> <port> <tty> <prompt> <fipdir>"
	exit 1
fi

UBOOT=$1
BOARD=$2
PORT=$3
TTY=$4
PROMPT=$5
FIPDIR=$6
DESTDIR=`mktemp -d`

case $BOARD in
	"libretech-cc")
	FIPDIR="$FIPDIR/lepotato"
    cp $FIPDIR/bl2.bin $DESTDIR/
    cp $FIPDIR/acs.bin $DESTDIR/
    cp $FIPDIR/bl21.bin $DESTDIR/
    cp $FIPDIR/bl30.bin $DESTDIR/
    cp $FIPDIR/bl301.bin $DESTDIR/
    cp $FIPDIR/bl31.img $DESTDIR/
    cp $UBOOT $DESTDIR/bl33.bin

    $FIPDIR/blx_fix.sh $DESTDIR/bl30.bin \
                       $DESTDIR/zero_tmp \
                       $DESTDIR/bl30_zero.bin \
                       $DESTDIR/bl301.bin \
                       $DESTDIR/bl301_zero.bin \
                       $DESTDIR/bl30_new.bin bl30

    python3 $FIPDIR/acs_tool.py $DESTDIR/bl2.bin $DESTDIR/bl2_acs.bin $DESTDIR/acs.bin 0

    $FIPDIR/blx_fix.sh $DESTDIR/bl2_acs.bin \
                       $DESTDIR/zero_tmp \
                       $DESTDIR/bl2_zero.bin \
                       $DESTDIR/bl21.bin \
                       $DESTDIR/bl21_zero.bin \
                       $DESTDIR/bl2_new.bin bl2

    $FIPDIR/aml_encrypt_gxl --bl3enc --input $DESTDIR/bl30_new.bin
    $FIPDIR/aml_encrypt_gxl --bl3enc --input $DESTDIR/bl31.img
    $FIPDIR/aml_encrypt_gxl --bl3enc --input $DESTDIR/bl33.bin
    $FIPDIR/aml_encrypt_gxl --bl2sig --input $DESTDIR/bl2_new.bin --output $DESTDIR/bl2.n.bin.sig
    $FIPDIR/aml_encrypt_gxl --bootmk --output $DESTDIR/u-boot.bin --bl2 $DESTDIR/bl2.n.bin.sig --bl30 $DESTDIR/bl30_new.bin.enc --bl31 $DESTDIR/bl31.img.enc --bl33 $DESTDIR/bl33.bin.enc
	;;

	*)
	echo "Unsupported board"
	exit 1
esac

stty -F /dev/$TTY 115200 cs8 parenb

sh lab-tools/amaz.sh -a off -p $PORT
sleep 1
sh lab-tools/amaz.sh -a on -p $PORT
sleep 1

pyamlboot/boot.py --board-files $DESTDIR/ $BOARD

N=0
while read -ra bytes
do
  echo "$N> $bytes"
  N=`expr $N + 1`
  if echo $bytes | grep $PROMPT ; then
	break
  fi
done < /dev/$TTY

sh lab-tools/amaz.sh -a off -p $PORT

exit 0

#!/bin/bash

set -ex

if [ "$#" -lt 4 ] ; then
	echo "Usage: $0 <toolchain> <u-boot-path> <board> <fipdir>"
	exit 1
fi

TOOLCHAIN=$1
UBOOT=$2
BOARD=$3
FIPDIR=$4

# Check if config exists, otherwise ignore
if ! [ -e $UBOOT/configs/${BOARD}_defconfig ] ; then
    echo "Unsupported board"
    exit 0
fi

# Build U-Boot
(
    cd $UBOOT
    make O=build_$BOARD ${BOARD}_defconfig > /dev/null
    make O=build_$BOARD CROSS_COMPILE=$TOOLCHAIN/aarch64-none-linux-gnu- -j4 > /dev/null
)

case $BOARD in
	"odroid-c2")
	FIPDIR="$FIPDIR/odroid-c2"
    SOC="odroid-c2"
    ;;
	"odroid-c4")
	FIPDIR="$FIPDIR/odroid-c4"
    SOC="sm1"
    ;;
	"odroid-n2")
	FIPDIR="$FIPDIR/odroid-n2"
    SOC="g12b"
    ;;
	"p212")
	FIPDIR="$FIPDIR/p212"
    SOC="gxl"
    ;;
	"s400")
	FIPDIR="$FIPDIR/s400"
    SOC="axg"
    ;;
	"p201")
	FIPDIR="$FIPDIR/p201"
    SOC="gxbb"
    ;;
	"p200")
	FIPDIR="$FIPDIR/p200"
    SOC="gxbb"
    ;;
	"u200")
	FIPDIR="$FIPDIR/u200"
    SOC="g12a"
    ;;
	"libretech-cc")
	FIPDIR="$FIPDIR/lepotato"
    SOC="gxl"
    ;;
	"libretech-cc_v2")
	FIPDIR="$FIPDIR/lepotato"
    SOC="gxl"
    ;;
	"libretech-ac")
	FIPDIR="$FIPDIR/lafrite"
    SOC="gxl"
    ;;
	"libretech-s905d-pc")
	FIPDIR="$FIPDIR/tartiflette-s905d"
    SOC="gxl"
    ;;
	"libretech-s912-pc")
	FIPDIR="$FIPDIR/tartiflette-s912"
    SOC="gxm"
    ;;
	"khadas-vim")
	FIPDIR="$FIPDIR/khadas-vim"
    SOC="gxl"
    ;;
	"khadas-vim2")
	FIPDIR="$FIPDIR/khadas-vim2"
    SOC="gxm"
    ;;
	"khadas-vim3")
	FIPDIR="$FIPDIR/khadas-vim3"
    SOC="g12b"
    ;;
	"khadas-vim3l")
	FIPDIR="$FIPDIR/khadas-vim3l"
    SOC="sm1"
    ;;
	"nanopi-k2")
	FIPDIR="$FIPDIR/nanopi-k2"
    SOC="gxbb"
    ;;
	"sei510")
	FIPDIR="$FIPDIR/sei510"
    SOC="g12a"
    ;;
	"sei610")
	FIPDIR="$FIPDIR/sei610"
    SOC="sm1"
    ;;
	"wetek-core2")
	FIPDIR="$FIPDIR/wetek-core2"
    SOC="gxl"
    ;;
	"beelink-gtking")
	FIPDIR="$FIPDIR/beelink-s922x"
    SOC="g12b"
    ;;
	"beelink-gtkingpro")
	FIPDIR="$FIPDIR/beelink-s922x"
    SOC="g12b"
    ;;
    *)
	echo "FIXME: No FIP for $BOARD"
	exit 0
esac

# Package with FIP
DESTDIR=$UBOOT/build_$BOARD/fip

mkdir -p $DESTDIR

make -C $FIPDIR TMP=${DESTDIR} O=${DESTDIR} BL33=$UBOOT/build_$BOARD/u-boot.bin

ls ${DESTDIR}/

exit 0

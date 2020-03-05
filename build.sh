#!/bin/bash

set -ex

if [ "$#" -lt 3 ] ; then
	echo "Usage: $0 <toolchain> <u-boot-path> <board>"
	exit 1
fi

(
    cd $2
    make -q O=build_$3 ${3}_defconfig
    make -q O=build_$3 CROSS_COMPILE=$1/aarch64-linux-gnu-
)

exit 0

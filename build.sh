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

# Build U-Boot
(
    cd $UBOOT
    make O=build_$BOARD ${BOARD}_defconfig > /dev/null
    make O=build_$BOARD CROSS_COMPILE=$TOOLCHAIN/aarch64-linux-gnu- -j4 > /dev/null
)

# Package with FIP
DESTDIR=$UBOOT/build_$BOARD/fip

case $BOARD in
	"odroid-c2")
	FIPDIR="$FIPDIR/odroid-c2"
    SOC="odroid-c2"
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
	exit 0
    ;;
	"p200")
	exit 0
    ;;
	"u200")
    # TODO
	exit 0
    ;;
	"libretech-cc")
	FIPDIR="$FIPDIR/lepotato"
    SOC="gxl"
    ;;
	"libretech-ac")
	FIPDIR="$FIPDIR/lafrite"
    SOC="gxl"
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
    SOC="g12a"
    # TODO
	exit 0
    ;;
	"sei610")
    SOC="sm1"
    # TODO
	exit 0
    ;;
    *)
	echo "Unsupported board"
	exit 1
esac

mkdir -p $DESTDIR

case $SOC in
	"gxbb")
    cp $FIPDIR/bl2.bin $DESTDIR/
    cp $FIPDIR/acs.bin $DESTDIR/
    cp $FIPDIR/bl21.bin $DESTDIR/
    cp $FIPDIR/bl30.bin $DESTDIR/
    cp $FIPDIR/bl301.bin $DESTDIR/
    cp $FIPDIR/bl31.img $DESTDIR/
    cp $UBOOT/build_$BOARD/u-boot.bin $DESTDIR/bl33.bin

    ${FIPDIR}/blx_fix.sh ${DESTDIR}/bl30.bin \
			 ${DESTDIR}/zero_tmp \
			 ${DESTDIR}/bl30_zero.bin \
			 ${DESTDIR}/bl301.bin \
			 ${DESTDIR}/bl301_zero.bin \
			 ${DESTDIR}/bl30_new.bin bl30

    ${FIPDIR}/fip_create --bl30 ${DESTDIR}/bl30_new.bin \
			 --bl31 ${DESTDIR}/bl31.img \
			 --bl33 ${DESTDIR}/bl33.bin \
			 ${DESTDIR}/fip.bin

    python3 ${FIPDIR}/acs_tool.pyc ${DESTDIR}/bl2.bin \
				  ${DESTDIR}/bl2_acs.bin \
				  ${DESTDIR}/acs.bin 0

    ${FIPDIR}/blx_fix.sh ${DESTDIR}/bl2_acs.bin \
			 ${DESTDIR}/zero_tmp \
			 ${DESTDIR}/bl2_zero.bin \
			 ${DESTDIR}/bl21.bin \
			 ${DESTDIR}/bl21_zero.bin \
			 ${DESTDIR}/bl2_new.bin bl2

    cat ${DESTDIR}/bl2_new.bin ${DESTDIR}/fip.bin > ${DESTDIR}/boot_new.bin

    ${FIPDIR}/aml_encrypt_gxb --bootsig --input ${DESTDIR}/boot_new.bin \
			      --output ${DESTDIR}/u-boot.bin
    ;;
    "odroid-c2" )
    cp $FIPDIR/bl2.package $DESTDIR/
    cp $FIPDIR/bl30.bin $DESTDIR/
    cp $FIPDIR/bl301.bin $DESTDIR/
    cp $FIPDIR/bl31.img $DESTDIR/
    cp $UBOOT/build_$BOARD/u-boot.bin $DESTDIR/bl33.bin

    ${FIPDIR}/fip_create --bl30 ${DESTDIR}/bl30.bin \
			 --bl301 ${DESTDIR}/bl301.bin \
			 --bl31 ${DESTDIR}/bl31.bin \
			 --bl33 ${DESTDIR}/bl33.bin \
			 ${DESTDIR}/fip.bin

    ${FIPDIR}/fip_create --dump ${DESTDIR}/fip.bin

    cat ${DESTDIR}/bl2.package ${DESTDIR}/fip.bin > ${DESTDIR}/boot_new.bin

    ${FIPDIR}/aml_encrypt_gxb --bootsig \
			      --input ${DESTDIR}/boot_new.bin \
			      --output ${DESTDIR}/u-boot.bin
    ;;
	"gxl" | "gxm")
    cp $FIPDIR/bl2.bin $DESTDIR/
    cp $FIPDIR/acs.bin $DESTDIR/
    cp $FIPDIR/bl21.bin $DESTDIR/
    cp $FIPDIR/bl30.bin $DESTDIR/
    cp $FIPDIR/bl301.bin $DESTDIR/
    cp $FIPDIR/bl31.img $DESTDIR/
    cp $UBOOT/build_$BOARD/u-boot.bin $DESTDIR/bl33.bin

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
	"axg")
    cp $FIPDIR/bl2.bin $DESTDIR/
    cp $FIPDIR/acs.bin $DESTDIR/
    cp $FIPDIR/bl21.bin $DESTDIR/
    cp $FIPDIR/bl30.bin $DESTDIR/
    cp $FIPDIR/bl301.bin $DESTDIR/
    cp $FIPDIR/bl31.img $DESTDIR/
    cp $UBOOT/build_$BOARD/u-boot.bin $DESTDIR/bl33.bin

    $FIPDIR/blx_fix.sh ${DESTDIR}/bl30.bin ${DESTDIR}/zero_tmp ${DESTDIR}/bl30_zero.bin ${DESTDIR}/bl301.bin ${DESTDIR}/bl301_zero.bin ${DESTDIR}/bl30_new.bin bl30

    python3 $FIPDIR/acs_tool.py ${DESTDIR}/bl2.bin ${DESTDIR}/bl2_acs.bin ${DESTDIR}/acs.bin 0

    $FIPDIR/blx_fix.sh ${DESTDIR}/bl2_acs.bin ${DESTDIR}/zero_tmp ${DESTDIR}/bl2_zero.bin ${DESTDIR}/bl21.bin ${DESTDIR}/bl21_zero.bin ${DESTDIR}/bl2_new.bin bl2

    ${FIPDIR}/aml_encrypt --bl3sig --input ${DESTDIR}/bl30_new.bin --output ${DESTDIR}/bl30_new.bin.enc --level v3 --type bl30
    ${FIPDIR}/aml_encrypt --bl3sig --input ${DESTDIR}/bl31.img --output ${DESTDIR}/bl31.img.enc --level v3 --type bl31
    ${FIPDIR}/aml_encrypt --bl3sig --input $DESTDIR/bl33.bin --output ${DESTDIR}/bl33.bin.enc --level v3 --type bl33 --compress lz4
    ${FIPDIR}/aml_encrypt --bl2sig --input ${DESTDIR}/bl2_new.bin --output ${DESTDIR}/bl2.n.bin.sig
    ${FIPDIR}/aml_encrypt --bootmk --output ${DESTDIR}/u-boot.bin \
	     --bl2 ${DESTDIR}/bl2.n.bin.sig \
	     --bl30 ${DESTDIR}/bl30_new.bin.enc \
	     --bl31 ${DESTDIR}/bl31.img.enc \
	     --bl33 ${DESTDIR}/bl33.bin.enc \
	     --level v3
	;;
	"g12a" | "sm1")
    cp $FIPDIR/bl2.bin $DESTDIR/
    cp $FIPDIR/acs.bin $DESTDIR/
    cp $FIPDIR/bl21.bin $DESTDIR/
    cp $FIPDIR/bl30.bin $DESTDIR/
    cp $FIPDIR/bl301.bin $DESTDIR/
    cp $FIPDIR/bl31.img $DESTDIR/
    cp $FIPDIR/*.fw $DESTDIR/
    cp $UBOOT/build_$BOARD/u-boot.bin $DESTDIR/bl33.bin

    $FIPDIR/blx_fix.sh ${DESTDIR}/bl30.bin ${DESTDIR}/zero_tmp ${DESTDIR}/bl30_zero.bin ${DESTDIR}/bl301.bin ${DESTDIR}/bl301_zero.bin ${DESTDIR}/bl30_new.bin bl30

    $FIPDIR/blx_fix.sh ${DESTDIR}/bl2.bin ${DESTDIR}/zero_tmp ${DESTDIR}/bl2_zero.bin ${DESTDIR}/acs.bin ${DESTDIR}/bl21_zero.bin ${DESTDIR}/bl2_new.bin bl2

    ${FIPDIR}/aml_encrypt_g12a --bl30sig --input ${DESTDIR}/bl30_new.bin --output ${DESTDIR}/bl30_new.bin.g12.enc --level v3
    ${FIPDIR}/aml_encrypt_g12a --bl3sig  --input ${DESTDIR}/bl30_new.bin.g12.enc --output ${DESTDIR}/bl30_new.bin.enc --level v3 --type bl30
    ${FIPDIR}/aml_encrypt_g12a --bl3sig  --input ${DESTDIR}/bl31.img --output ${DESTDIR}/bl31.img.enc --level v3 --type bl31
    ${FIPDIR}/aml_encrypt_g12a --bl3sig  --input $DESTDIR/bl33.bin --compress lz4 --output ${DESTDIR}/bl33.bin.enc --level v3 --type bl33
    ${FIPDIR}/aml_encrypt_g12a --bl2sig  --input ${DESTDIR}/bl2_new.bin --output ${DESTDIR}/bl2.n.bin.sig
    if [ -e ${DESTDIR}/lpddr3_1d.fw ]
    then
	    ${FIPDIR}/aml_encrypt_g12a --bootmk  --output ${DESTDIR}/u-boot.bin \
		     --bl2 ${DESTDIR}/bl2.n.bin.sig \
		     --bl30 ${DESTDIR}/bl30_new.bin.enc \
		     --bl31 ${DESTDIR}/bl31.img.enc \
		     --bl33 ${DESTDIR}/bl33.bin.enc \
		     --ddrfw1 ${FIPDIR}/ddr4_1d.fw \
		     --ddrfw2 ${FIPDIR}/ddr4_2d.fw \
		     --ddrfw3 ${FIPDIR}/ddr3_1d.fw \
		     --ddrfw4 ${FIPDIR}/piei.fw \
		     --ddrfw5 ${FIPDIR}/lpddr4_1d.fw \
		     --ddrfw6 ${FIPDIR}/lpddr4_2d.fw \
		     --ddrfw7 ${FIPDIR}/diag_lpddr4.fw \
		     --ddrfw8 ${FIPDIR}/aml_ddr.fw \
		     --ddrfw9 ${FIPDIR}/lpddr3_1d.fw \
		     --level v3
    else
	    ${FIPDIR}/aml_encrypt_g12a --bootmk  --output ${DESTDIR}/u-boot.bin \
		     --bl2 ${DESTDIR}/bl2.n.bin.sig \
		     --bl30 ${DESTDIR}/bl30_new.bin.enc \
		     --bl31 ${DESTDIR}/bl31.img.enc \
		     --bl33 ${DESTDIR}/bl33.bin.enc \
		     --ddrfw1 ${FIPDIR}/ddr4_1d.fw \
		     --ddrfw2 ${FIPDIR}/ddr4_2d.fw \
		     --ddrfw3 ${FIPDIR}/ddr3_1d.fw \
		     --ddrfw4 ${FIPDIR}/piei.fw \
		     --ddrfw5 ${FIPDIR}/lpddr4_1d.fw \
		     --ddrfw6 ${FIPDIR}/lpddr4_2d.fw \
		     --ddrfw7 ${FIPDIR}/diag_lpddr4.fw \
		     --ddrfw8 ${FIPDIR}/aml_ddr.fw \
		     --level v3
    fi
    ;;
	"g12b")
    cp $FIPDIR/bl2.bin $DESTDIR/
    cp $FIPDIR/acs.bin $DESTDIR/
    cp $FIPDIR/bl21.bin $DESTDIR/
    cp $FIPDIR/bl30.bin $DESTDIR/
    cp $FIPDIR/bl301.bin $DESTDIR/
    cp $FIPDIR/bl31.img $DESTDIR/
    cp $FIPDIR/*.fw $DESTDIR/
    cp $UBOOT/build_$BOARD/u-boot.bin $DESTDIR/bl33.bin

    $FIPDIR/blx_fix.sh ${DESTDIR}/bl30.bin ${DESTDIR}/zero_tmp ${DESTDIR}/bl30_zero.bin ${DESTDIR}/bl301.bin ${DESTDIR}/bl301_zero.bin ${DESTDIR}/bl30_new.bin bl30

    $FIPDIR/blx_fix.sh ${DESTDIR}/bl2.bin ${DESTDIR}/zero_tmp ${DESTDIR}/bl2_zero.bin ${DESTDIR}/acs.bin ${DESTDIR}/bl21_zero.bin ${DESTDIR}/bl2_new.bin bl2

    ${FIPDIR}/aml_encrypt_g12b --bl30sig --input ${DESTDIR}/bl30_new.bin --output ${DESTDIR}/bl30_new.bin.g12.enc --level v3
    ${FIPDIR}/aml_encrypt_g12b --bl3sig  --input ${DESTDIR}/bl30_new.bin.g12.enc --output ${DESTDIR}/bl30_new.bin.enc --level v3 --type bl30
    ${FIPDIR}/aml_encrypt_g12b --bl3sig  --input ${DESTDIR}/bl31.img --output ${DESTDIR}/bl31.img.enc --level v3 --type bl31
    ${FIPDIR}/aml_encrypt_g12b --bl3sig  --input $DESTDIR/bl33.bin --compress lz4 --output ${DESTDIR}/bl33.bin.enc --level v3 --type bl33
    ${FIPDIR}/aml_encrypt_g12b --bl2sig  --input ${DESTDIR}/bl2_new.bin --output ${DESTDIR}/bl2.n.bin.sig
    if [ -e ${DESTDIR}/lpddr3_1d.fw ]
    then
	    ${FIPDIR}/aml_encrypt_g12b --bootmk  --output ${DESTDIR}/u-boot.bin \
		     --bl2 ${DESTDIR}/bl2.n.bin.sig \
		     --bl30 ${DESTDIR}/bl30_new.bin.enc \
		     --bl31 ${DESTDIR}/bl31.img.enc \
		     --bl33 ${DESTDIR}/bl33.bin.enc \
		     --ddrfw1 ${FIPDIR}/ddr4_1d.fw \
		     --ddrfw2 ${FIPDIR}/ddr4_2d.fw \
		     --ddrfw3 ${FIPDIR}/ddr3_1d.fw \
		     --ddrfw4 ${FIPDIR}/piei.fw \
		     --ddrfw5 ${FIPDIR}/lpddr4_1d.fw \
		     --ddrfw6 ${FIPDIR}/lpddr4_2d.fw \
		     --ddrfw7 ${FIPDIR}/diag_lpddr4.fw \
		     --ddrfw8 ${FIPDIR}/aml_ddr.fw \
		     --ddrfw9 ${FIPDIR}/lpddr3_1d.fw \
		     --level v3
    else
	    ${FIPDIR}/aml_encrypt_g12b --bootmk  --output ${DESTDIR}/u-boot.bin \
		     --bl2 ${DESTDIR}/bl2.n.bin.sig \
		     --bl30 ${DESTDIR}/bl30_new.bin.enc \
		     --bl31 ${DESTDIR}/bl31.img.enc \
		     --bl33 ${DESTDIR}/bl33.bin.enc \
		     --ddrfw1 ${FIPDIR}/ddr4_1d.fw \
		     --ddrfw2 ${FIPDIR}/ddr4_2d.fw \
		     --ddrfw3 ${FIPDIR}/ddr3_1d.fw \
		     --ddrfw4 ${FIPDIR}/piei.fw \
		     --ddrfw5 ${FIPDIR}/lpddr4_1d.fw \
		     --ddrfw6 ${FIPDIR}/lpddr4_2d.fw \
		     --ddrfw7 ${FIPDIR}/diag_lpddr4.fw \
		     --ddrfw8 ${FIPDIR}/aml_ddr.fw \
		     --level v3
    fi
    ;;
esac

ls ${DESTDIR}/

exit 0

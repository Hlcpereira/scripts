#!/bin/bash
# Scripts originally created by Jonas Cardoso <jonascard60@gmail.com> and Xhoni Rexhepi aka PsyMan47 <xhonirexhepi@gmail.com>
# Adapted and unified by Henrique Pereira aka Hlcpereira <pereirah2001@gmail.com>

_unset_and_stop() {
	unset DEVICE KERNEL_DIR VARIANT
	break
}

unset DEVICE KERNEL_DIR VARIANT _option_exit

for _u2t in "${@}"
do
	if [[ "${_u2t}" == *"help" ]]
		then
		echo "  |"
		echo "  | Usage:"
		echo "  | --help           | To show this message"
		echo "  |"
		echo "  | -e | --eas       | To build EAS kernel (Xiaomi msm8996 devices only)"
		echo "  | -h | --hmp       | To build HMP kernel (Xiaomi msm8996 devices only)"
		echo "  |"
		echo "  | -0 | --gemini    | To build only for Mi5 (Gemini)"
		echo "  | -1 | --capricorn | To build only for Mi5S (Capricorn)"
		echo "  | -2 | --natrium   | To build only for Mi5S Plus (Natrium)"
		echo "  | -3 | --lithium   | To build only for Mi Mix (Lithium)"
		echo "  | -4 | --scorpio   | To build only for Mi Note 2 (Scorpio)"
		echo "  | -5 | --oneplus5  | To build only for OnePlus5/5T (Oneplus5)"
		echo "  |"
		_option_exit="1"
		_unset_and_stop
	fi
	# Choose device before menu
	if [[ "${_u2t}" == *"0" ]] || [[ "${_u2t}" == *"gemini" ]]
	then
		DEVICE=gemini DEFCONFIG=gemini_defconfig ANYKERNEL_DIR=./AnyKernel2-xiaomi-msm8996
	fi
	if [[ "${_u2t}" == *"1" ]] || [[ "${_u2t}" == *"capricorn" ]]
	then
		DEVICE=capricorn DEFCONFIG=capricorn_defconfig ANYKERNEL_DIR=./AnyKernel2-xiaomi-msm8996
	fi
	if [[ "${_u2t}" == *"2" ]] || [[ "${_u2t}" == *"natrium" ]]
	then
		DEVICE=natrium DEFCONFIG=natrium_defconfig ANYKERNEL_DIR=./AnyKernel2-xiaomi-msm8996
	fi
	if [[ "${_u2t}" == *"3" ]] || [[ "${_u2t}" == *"lithium" ]]
	then
		DEVICE=lithium DEFCONFIG=lithium_defconfig ANYKERNEL_DIR=./AnyKernel2-xiaomi-msm8996
	fi
	if [[ "${_u2t}" == *"4" ]] || [[ "${_u2t}" == *"scorpio" ]]
	then
		DEVICE=scorpio DEFCONFIG=scorpio_defconfig ANYKERNEL_DIR=./AnyKernel2-xiaomi-msm8996
	fi
	if [[ "${_u2t}" == *"5" ]] || [[ "${_u2t}" == *"oneplus5" ]]
	then
		DEVICE=oneplus5 DEFCONFIG=oneplus5_defconfig ANYKERNEL_DIR=./AnyKernel2-oneplus5 KERNEL_DIR=~/Kernelx/oneplus5 \
		FINAL_ZIP="$KERNEL_NAME""-$DEVICE-""$DATE".zip
	fi
        if [[ "${_u2t}" == *"h" ]] || [[ "${_u2t}" == *"hmp" ]]
        then
                KERNEL_DIR=~/Kernelx/xiaomi-msm8996-hmp VARIANT="-HMP" FINAL_ZIP="$KERNEL_NAME""-$DEVICE-""$DATE""$VARIANT".zip
        fi
        if [[ "${_u2t}" == *"e" ]] || [[ "${_u2t}" == *"eas" ]]
        then
                KERNEL_DIR=~/Kernelx/xiaomi-msm8996-eas VARIANT="-EAS" FINAL_ZIP="$KERNEL_NAME""-$DEVICE-""$DATE""$VARIANT".zip
        fi
done

# Exit if option is 'help'
if [ "${_option_exit}" != "" ]
then
	_unset_and_stop
fi

if [ "${DEVICE}" == "" ]
then
    _unset_and_stop
fi
echo "  | Building for $DEVICE"

DATE=$(date +"%Y%m%d")
KERNEL_NAME="KernelX"
OUT_DIR=./out

if [ -e "./out" ]
then
    rm $OUT_DIR/*.zip
else
    mkdir $OUT_DIR
fi
rm $ANYKERNEL_DIR/Image.gz-dtb
rm $ANYKERNEL_DIR/device.prop
rm $KERNEL_DIR/arch/arm64/boot/Image.gz $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb

export ARCH=arm64
export CROSS_COMPILE=~/Kernelx/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
#export CLANG_TRIPLE=aarch64-linux-android-
#export CLANG_PATH=./toolchain/clang/7.0-DragonTC/bin

cd $KERNEL_DIR
make clean && make mrproper
make $DEFCONFIG
make -j$( nproc --all )
cd ..

echo "name1=$DEVICE" >> $ANYKERNEL_DIR/device.prop
cp $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR
cd $ANYKERNEL_DIR
zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
cd ..
mv $ANYKERNEL_DIR/*.zip $OUT_DIR/

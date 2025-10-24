#!/usr/bin/env bash

set -uexo pipefail

which 7z
which git
which python

mv $OUT_PATH/uboot.zip ./
7z x uboot.zip -o./uboot
cp uboot/.output/u-boot.img $OUT_PATH/images/uboot.img

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output $OUT_PATH/images/vbmeta-disabled.img

install -Dm 0755 $DEVICE_PATH/scripts/flash-xiaomi-nabu.sh $OUT_PATH/flash-xiaomi-nabu.sh
install -Dm 0755 $DEVICE_PATH/scripts/flash-xiaomi-nabu.cmd $OUT_PATH/flash-xiaomi-nabu.cmd

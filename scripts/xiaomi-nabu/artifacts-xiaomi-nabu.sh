#!/usr/bin/env bash

set -uexo pipefail

which 7z
which git
which curl
which python

curl -L https://github.com/ArKT-7/twrp_device_xiaomi_nabu/releases/download/mod_linux/V4-MODDED-TWRP-LINUX.img -o images/twrp.img
curl -L https://github.com/ArKT-7/automated-nabu-lineage-installer/releases/download/lineage-22.1-20250207-UNOFFICIAL-nabu/dtbo.img -o images/dtbo.img
curl -L https://github.com/gmankab/sgdisk/releases/download/v1.0.10/sgdisk -o images/sgdisk
curl -L https://github.com/gmankab/parted/releases/download/v3.6/parted -o images/parted

curl -L https://gitlab.com/sm8150-mainline/u-boot/-/jobs/10969839675/artifacts/download -o uboot.zip
7z x uboot.zip -o./uboot
cp uboot/.output/u-boot.img images/uboot.img

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output images/vbmeta-disabled.img

install -Dm 0755 scripts/xiaomi-nabu/flash-xiaomi-nabu.sh flash-xiaomi-nabu.sh
install -Dm 0755 scripts/xiaomi-nabu/flash-xiaomi-nabu.cmd flash-xiaomi-nabu.cmd
install -Dm 0755 scripts/xiaomi-nabu/flash-xiaomi-nabu-ps.bat flash-xiaomi-nabu-ps.bat

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash-xiaomi-nabu* images

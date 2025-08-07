#!/usr/bin/env bash

set -uexo pipefail

which 7z
which git
which curl
which python

curl -L https://github.com/map220v/android_device_xiaomi_nabu/releases/download/nabu_twrp-12.1_20230531/boot.img -o images/twrp.img
curl -L https://github.com/ArKT-7/automated-nabu-lineage-installer/releases/download/lineage-22.1-20250207-UNOFFICIAL-nabu/dtbo.img -o images/dtbo.img
curl -L https://github.com/gmankab/sgdisk/releases/download/v1.0.10/sgdisk -o images/sgdisk
curl -L https://github.com/gmankab/parted/releases/download/v3.6/parted -o images/parted

curl -L https://gitlab.com/sm8150-mainline/u-boot/-/jobs/9720400108/artifacts/download -o uboot.zip
7z x uboot.zip -o./uboot
cp uboot/.output/u-boot.img images/uboot.img

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output images/vbmeta_disabled.img

install -Dm 0755 scripts/flash_mipad5.sh flash_mipad5.sh

7z -mx=9 a "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash_mipad5.sh images

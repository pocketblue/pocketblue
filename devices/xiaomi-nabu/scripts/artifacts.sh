#!/usr/bin/env bash

set -uexo pipefail

which 7z
which git
which curl
which python

curl -L https://gitlab.com/sm8150-mainline/u-boot/-/jobs/10969839675/artifacts/download -o uboot.zip

sha256sum -c $(dirname "$0")/checksums

7z x uboot.zip -o./uboot

cp uboot/.output/u-boot.img images/uboot.img
git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output images/vbmeta-disabled.img
install -Dm 0755 devices/xiaomi-nabu/scripts/flash-xiaomi-nabu.sh flash-xiaomi-nabu.sh
install -Dm 0755 devices/xiaomi-nabu/scripts/flash-xiaomi-nabu.cmd flash-xiaomi-nabu.cmd

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash-xiaomi-nabu* images

#!/usr/bin/env bash

set -uexo pipefail

which 7z

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output images/vbmeta-disabled.img

install -Dm 0755 devices/xiaomi-pipa/scripts/flash-xiaomi-pipa.sh flash-xiaomi-pipa.sh
install -Dm 0755 devices/xiaomi-pipa/scripts/flash-xiaomi-pipa.cmd flash-xiaomi-pipa.cmd

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash-xiaomi-pipa.* images

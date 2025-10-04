#!/usr/bin/env bash

set -uexo pipefail

which 7z
which curl

curl -L https://github.com/timoxa0/kxboot-pipa/releases/download/v1.0.1/kxboot-pipa.img -o images/kxboot.img

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output images/vbmeta-disabled.img

install -Dm 0755 scripts/xiaomi-pipa/flash-xiaomi-pipa.sh flash-xiaomi-pipa.sh

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash-xiaomi-pipa* images

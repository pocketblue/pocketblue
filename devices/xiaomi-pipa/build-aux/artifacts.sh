#!/usr/bin/env bash

set -uexo pipefail

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output $OUT_PATH/images/vbmeta-disabled.img

install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-pipa.sh $OUT_PATH/flash-xiaomi-pipa.sh
install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-pipa.cmd $OUT_PATH/flash-xiaomi-pipa.cmd

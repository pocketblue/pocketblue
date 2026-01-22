#!/usr/bin/env bash

set -uexo pipefail

which 7z
which git
which python

mv $OUT_PATH/aloha.zip ./
7z x aloha.zip -o./aloha
cp aloha/xiaomi-nabu/xiaomi-nabu_NOSB.img $OUT_PATH/images/aloha.img

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output $OUT_PATH/images/vbmeta-disabled.img

# install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-nabu.sh $OUT_PATH/flash-xiaomi-nabu.sh
# install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-nabu.cmd $OUT_PATH/flash-xiaomi-nabu.cmd

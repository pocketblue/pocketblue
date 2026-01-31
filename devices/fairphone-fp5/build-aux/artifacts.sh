#!/usr/bin/env bash

set -uexo pipefail

which 7z
which git
which python

git clone --depth=1 https://android.googlesource.com/platform/external/avb
python avb/avbtool.py make_vbmeta_image --flags 2 --padding_size 4096 --output $OUT_PATH/images/vbmeta-disabled.img

install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-fairphone-fp5.sh  $OUT_PATH/flash-fairphone-fp5.sh
install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-fairphone-fp5.cmd $OUT_PATH/flash-fairphone-fp5.cmd

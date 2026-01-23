#!/usr/bin/env bash

set -uexo pipefail

install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-beryllium.sh.in  $OUT_PATH/flash-xiaomi-beryllium-ebbg.sh
install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-beryllium.sh.in  $OUT_PATH/flash-xiaomi-beryllium-tianma.sh
install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-beryllium.cmd.in $OUT_PATH/flash-xiaomi-beryllium-ebbg.cmd
install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-xiaomi-beryllium.cmd.in $OUT_PATH/flash-xiaomi-beryllium-tianma.cmd

sed -i 's/@panel@/ebbg/g'   $OUT_PATH/flash-xiaomi-beryllium-ebbg.*
sed -i 's/@panel@/tianma/g' $OUT_PATH/flash-xiaomi-beryllium-tianma.*

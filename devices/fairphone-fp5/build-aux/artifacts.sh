#!/usr/bin/env bash

set -uexo pipefail

install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-fairphone-fp5.sh  $OUT_PATH/flash-fairphone-fp5.sh
install -Dm 0755 $DEVICE_PATH/flash-scripts/flash-fairphone-fp5.cmd $OUT_PATH/flash-fairphone-fp5.cmd

#!/usr/bin/env bash

set -uexo pipefail

install -Dm 0755 $DEVICE_PATH/flash-scripts/flash.sh $OUT_PATH/flash.sh

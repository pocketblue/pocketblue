#!/usr/bin/env bash

set -uexo pipefail

install -Dm 0755 devices/oneplus-sdm845/flash-scripts/flash-oneplus-sdm845.sh.in     $OUT_PATH/flash-oneplus6-enchilada.sh
install -Dm 0755 devices/oneplus-sdm845/flash-scripts/flash-oneplus-sdm845.sh.in     $OUT_PATH/flash-oneplus6t-fajita.sh
install -Dm 0755 devices/oneplus-sdm845/flash-scripts/flash-oneplus-sdm845.cmd.in    $OUT_PATH/flash-oneplus6-enchilada.cmd
install -Dm 0755 devices/oneplus-sdm845/flash-scripts/flash-oneplus-sdm845.cmd.in    $OUT_PATH/flash-oneplus6t-fajita.cmd

sed -i 's/@device@/enchilada/g' $OUT_PATH/flash-oneplus6-enchilada.*
sed -i 's/@device@/fajita/g'    $OUT_PATH/flash-oneplus6t-fajita.*

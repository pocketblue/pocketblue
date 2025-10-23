#!/usr/bin/env bash

set -uexo pipefail

which 7z

install -Dm 0755 devices/oneplus-sdm845/scripts/flash-oneplus-sdm845.sh.in     flash-oneplus6-enchilada.sh
install -Dm 0755 devices/oneplus-sdm845/scripts/flash-oneplus-sdm845.sh.in     flash-oneplus6t-fajita.sh
install -Dm 0755 devices/oneplus-sdm845/scripts/flash-oneplus-sdm845.cmd.in    flash-oneplus6-enchilada.cmd
install -Dm 0755 devices/oneplus-sdm845/scripts/flash-oneplus-sdm845.cmd.in    flash-oneplus6t-fajita.cmd

sed -i 's/@device@/enchilada/g' flash-oneplus6-enchilada.*
sed -i 's/@device@/fajita/g'    flash-oneplus6t-fajita.*

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash-oneplus6* images

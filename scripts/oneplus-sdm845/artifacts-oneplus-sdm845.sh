#!/usr/bin/env bash

set -uexo pipefail

which 7z
which curl

curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-enchilada.img -o images/uboot-enchilada.img
curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-fajita.img -o images/uboot-fajita.img

install -Dm 0755 scripts/oneplus-sdm845/flash-oneplus-sdm845.sh.in     flash-oneplus6-enchilada.sh
install -Dm 0755 scripts/oneplus-sdm845/flash-oneplus-sdm845.sh.in     flash-oneplus6t-fajita.sh
install -Dm 0755 scripts/oneplus-sdm845/flash-oneplus-sdm845.cmd.in    flash-oneplus6-enchilada.cmd
install -Dm 0755 scripts/oneplus-sdm845/flash-oneplus-sdm845.cmd.in    flash-oneplus6t-fajita.cmd
install -Dm 0755 scripts/oneplus-sdm845/flash-oneplus-sdm845-ps.bat.in flash-oneplus6-enchilada-ps.bat
install -Dm 0755 scripts/oneplus-sdm845/flash-oneplus-sdm845-ps.bat.in flash-oneplus6t-fajita-ps.bat

sed -i 's/@device@/enchilada/g' flash-oneplus6-enchilada.*
sed -i 's/@device@/fajita/g'    flash-oneplus6t-fajita.*

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash-oneplus6* images

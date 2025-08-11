#!/usr/bin/env bash

set -uexo pipefail

which 7z
which curl

curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-enchilada.img -o images/uboot-enchilada.img
curl -L https://github.com/fedora-remix-mobility/u-boot/releases/download/fedora-mobility-v0.0.1/uboot-sdm845-oneplus-fajita.img -o images/uboot-fajita.img

install -Dm 0755 scripts/flash_oneplus6.sh.in flash_oneplus6_enchilada.sh
install -Dm 0755 scripts/flash_oneplus6.sh.in flash_oneplus6t_fajita.sh

sed -i 's/@device@/enchilada/g' flash_oneplus6_enchilada.sh
sed -i 's/@device@/fajita/g'    flash_oneplus6t_fajita.sh

7z a -mx=9 $ARGS_7Z "pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" flash_oneplus6*.sh images

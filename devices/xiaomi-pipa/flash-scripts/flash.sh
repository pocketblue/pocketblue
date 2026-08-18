#!/usr/bin/env bash

set -ueo pipefail

which fastboot

echo ">>> Flashing xiaomi-pipa"

echo '>>> Waiting for device to appear in fastboot...'
fastboot getvar product 2>&1 | grep pipa

echo '>>> (1/6) Erasing DTBO'
fastboot erase dtbo_ab

echo '>>> (2/6) Disabling verified boot'
fastboot flash vbmeta_ab images/vbmeta-disabled.img

echo '>>> (3/6) Flashing Silicium'
fastboot flash boot_ab images/silicium.img

echo ">>> (4/6) Flashing fedora_esp.raw into rawdump"
fastboot flash rawdump images/fedora_esp.raw

echo ">>> (5/6) Flashing fedora_rootfs.raw into userdata"
fastboot flash userdata images/fedora_rootfs.raw

echo '>>> (6/6) Writing to disk and rebooting (this may take a while, DO NOT DISCONNECT THE DEVICE)'
fastboot reboot

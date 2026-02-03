#!/usr/bin/env bash

set -uexo pipefail

which fastboot

echo 'waiting for device to appear in fastboot'

fastboot getvar product 2>&1 | grep -i fp5

fastboot erase dtbo
fastboot erase vendor_boot
#fastboot flash vbmeta   images/vbmeta-disabled.img
fastboot flash logdump  images/fedora_esp.raw  -S 256M
fastboot flash rawdump  images/fedora_boot.raw -S 256M
fastboot flash userdata images/fedora_rootfs.raw -S 256M
fastboot flash boot     images/u-boot.img --slot=all

echo 'done flashing, rebooting now'
fastboot reboot

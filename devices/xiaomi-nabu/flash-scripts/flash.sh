#!/usr/bin/env bash

set -uexo pipefail

which fastboot

echo 'waiting for device appear in fastboot'

fastboot getvar product 2>&1 | grep nabu
fastboot erase dtbo_ab
fastboot flash vbmeta_ab images/vbmeta-disabled.img
fastboot flash   boot_ab images/uboot.img
fastboot flash   rawdump images/fedora_esp.raw
fastboot flash      cust images/fedora_boot.raw
fastboot flash  userdata images/fedora_rootfs.raw

echo 'done flashing, rebooting now'
fastboot reboot

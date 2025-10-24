#!/usr/bin/env bash

set -uexo pipefail

which fastboot

set +x
echo 'waiting for device appear in fastboot'
set -x

fastboot getvar product 2>&1 | grep pipa
fastboot erase dtbo_ab
fastboot flash vbmeta_ab images/vbmeta-disabled.img
fastboot flash   boot_ab images/kxboot.img
fastboot flash   rawdump images/fedora_esp.raw
fastboot flash      cust images/fedora_boot.raw
fastboot flash  userdata images/fedora_rootfs.raw

set +x
echo 'done flashing, rebooting device now'
set -x

fastboot reboot

#!/usr/bin/env bash

set -uexo pipefail

which fastboot

set +x
echo 'waiting for device appear in fastboot'
set -x

fastboot getvar product 2>&1 | grep pipa
fastboot flash vbmeta_ab images/vbmeta_disabled.img
fastboot erase   dtbo_ab
fastboot flash   boot_ab images/kxboot.img
fastboot flash      cust images/esp.raw
fastboot flash     super images/boot.raw
fastboot flash  userdata images/root.raw

set +x
echo 'done flashing, rebooting device now'
set -x

fastboot reboot

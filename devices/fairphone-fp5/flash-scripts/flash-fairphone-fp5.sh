#!/usr/bin/env bash

set -uexo pipefail

which fastboot

echo 'waiting for device to appear in fastboot'

fastboot getvar product 2>&1 | grep -i fp5
fastboot flash rawdump   images/fedora_esp.raw
fastboot flash cust      images/fedora_boot.raw
fastboot flash userdata  images/fedora_rootfs.raw

echo 'done flashing, rebooting now'
fastboot reboot

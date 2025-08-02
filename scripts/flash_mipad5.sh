#!/usr/bin/env bash

set -uexo pipefail

echo 'waiting for device appear in fastboot'
fastboot getvar product 2>&1 | grep nabu
fastboot flash vbmeta_ab images/vbmeta_disabled.img
fastboot flash   dtbo_ab images/dtbo.img
fastboot flash   boot_ab images/twrp.img
fastboot reboot

set +x
echo 'waiting for device appear in adb'
until adb devices 2>/dev/null | grep recovery --silent ; do sleep 1; done
set -x

adb shell getprop ro.product.device | grep nabu
adb push images/parted /bin/parted
adb shell 'if [ -e /dev/block/sda31 ]; then parted -s /dev/block/sda rm 31; fi'
adb shell 'if [ -e /dev/block/sda32 ]; then parted -s /dev/block/sda rm 32; fi'
adb shell 'if [ -e /dev/block/sda33 ]; then parted -s /dev/block/sda rm 33; fi'
adb shell 'if [ -e /dev/block/sda34 ]; then parted -s /dev/block/sda rm 34; fi'
adb shell 'if [ -e /dev/block/sda35 ]; then parted -s /dev/block/sda rm 35; fi'
export start=$(adb shell parted -m /dev/block/sda print free | tail -1 | cut -d: -f2)
adb shell parted -s /dev/block/sda -- mkpart userdata    ext4 $start -3GB
adb shell parted -s /dev/block/sda -- mkpart fedora_boot ext4   -3GB -1GB
adb shell parted -s /dev/block/sda -- mkpart esp         fat32  -1GB 100%
adb reboot bootloader

fastboot getvar product 2>&1 | grep nabu
fastboot erase dtbo_ab
fastboot flash boot_ab     images/uboot.img
fastboot flash esp         images/esp.raw
fastboot flash fedora_boot images/boot.raw
fastboot flash userdata    images/root.raw
fastboot reboot

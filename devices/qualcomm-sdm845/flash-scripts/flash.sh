#!/usr/bin/env bash

set -ueo pipefail

which fastboot > /dev/null

echo '1. OnePlus 6 [oneplus-enchilada]'
echo '2. OnePlus 6T [oneplus-fajita]'
echo '3. Xiaomi Poco F1 (EBBG panel) [xiaomi-beryllium-ebbg]'
echo '4. Xiaomi Poco F1 (tianma panel) [xiaomi-beryllium-tianma]'
read -p 'Select the device (1-4, 0 to cancel) [0]: ' choice

case $choice in
1)
    device=oneplus-enchilada
    product_name=sdm845
    has_slots=true
    esp_part=system_b
    boot_part=system_a
    root_part=userdata
    ;;
2)
    device=oneplus-fajita
    product_name=sdm845
    has_slots=true
    esp_part=system_b
    boot_part=system_a
    root_part=userdata
    ;;
3)
    device=xiaomi-beryllium-ebbg
    product_name=beryllium
    has_slots=false
    esp_part=cust
    boot_part=system
    root_part=userdata
    ;;
4)
    device=xiaomi-beryllium-tianma
    product_name=beryllium
    has_slots=false
    esp_part=cust
    boot_part=system
    root_part=userdata
    ;;
*)
    exit
    ;;
esac

echo ">>> Flashing $device"

echo '>>> Waiting for device to appear in fastboot...'
fastboot getvar product 2>&1 | grep "$product_name"

if [ "$has_slots" = "true" ]; then
    echo '>>> (1/6) Erasing DTBO'
    fastboot erase dtbo_a
    fastboot erase dtbo_b
    echo '>>> (2/6) Flashing U-Boot'
    fastboot flash boot images/u-boot-$device.img --slot=all
else
    echo '>>> (1/6) Erasing DTBO'
    fastboot erase dtbo
    echo '>>> (2/6) Flashing U-Boot'
    fastboot flash boot images/u-boot-$device.img
fi

echo ">>> (3/6) Flashing fedora_esp.raw into $esp_part"
fastboot flash $esp_part images/fedora_esp.raw

echo ">>> (4/6) Flashing fedora_boot.raw into $boot_part"
fastboot flash $boot_part images/fedora_boot.raw

echo ">>> (5/6) Flashing fedora_rootfs.raw into $root_part"
fastboot flash $root_part images/fedora_rootfs.raw

echo '>>> (6/6) Rebooting (this may take a while, DO NOT DISCONNECT THE DEVICE)'
fastboot reboot

#!/usr/bin/env bash

set -uexo pipefail

which fastboot

check_image_size() {
    local partition="$1"
    local image="$2"
    
    if [[ ! -f "$image" ]]; then
        echo "ERROR: Image file not found: $image"
        exit 1
    fi
    
    local image_size
    image_size=$(stat -c%s "$image" 2>/dev/null || stat -f%z "$image" 2>/dev/null)
    
    local partition_size_hex
    partition_size_hex=$(fastboot getvar partition-size:"$partition" 2>&1 | grep -i "partition-size" | awk '{print $2}')
    
    if [[ -z "$partition_size_hex" ]]; then
        echo "WARNING: Could not get partition size for $partition, skipping size check"
        return 0
    fi
    
    local partition_size
    partition_size=$((partition_size_hex))
    
    echo "Partition $partition size: $partition_size bytes"
    echo "Image $image size: $image_size bytes"
    
    if [[ "$image_size" -gt "$partition_size" ]]; then
        echo "ERROR: Image $image ($image_size bytes) is larger than partition $partition ($partition_size bytes)"
        exit 1
    fi
    
    echo "OK: Image fits in partition ($(( (partition_size - image_size) / 1024 / 1024 )) MB free)"
}

flash_image() {
    local partition="$1"
    local image="$2"
    
    fastboot flash "$partition" "$image"
}

echo 'waiting for device to appear in fastboot'

fastboot getvar product 2>&1 | grep -i fp5

echo 'Checking image sizes against partition sizes...'
check_image_size rawdump  images/fedora_esp.raw
check_image_size logdump  images/fedora_boot.raw
check_image_size userdata images/fedora_rootfs.raw

echo 'All image size checks passed, proceeding with flash...'

fastboot erase dtbo
fastboot erase vendor_boot
# fastboot flash vbmeta    images/vbmeta-disabled.img
fastboot flash boot      images/u-boot.img --slot=all
flash_image rawdump      images/fedora_esp.raw
flash_image logdump      images/fedora_boot.raw
flash_image userdata     images/fedora_rootfs.raw

echo 'done flashing, rebooting now'
sleep 10
fastboot reboot

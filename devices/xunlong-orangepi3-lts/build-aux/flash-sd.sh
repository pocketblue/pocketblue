#!/usr/bin/env bash

set -euo pipefail

device="${1:-}"
images_dir="${2:-images}"

if [ -z "$device" ]; then
    echo "Usage: $0 <block-device> [images-dir]" >&2
    echo "Example: $0 /dev/sdX images" >&2
    exit 1
fi

if [ ! -b "$device" ]; then
    echo "Block device not found: $device" >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root (needed for partitioning and dd)" >&2
    exit 1
fi

esp_image="$images_dir/fedora_esp.raw"
boot_image="$images_dir/fedora_boot.raw"
rootfs_image="$images_dir/fedora_rootfs.raw"
uboot_bin="$images_dir/u-boot-sunxi-with-spl.bin"

for image in "$esp_image" "$boot_image" "$rootfs_image" "$uboot_bin"; do
    if [ ! -f "$image" ]; then
        echo "Missing image: $image" >&2
        exit 1
    fi
done

get_size_mib() {
    local bytes
    bytes=$(stat -c %s "$1" 2>/dev/null || wc -c < "$1")
    echo $(( (bytes + 1048576 - 1) / 1048576 ))
}

esp_size_mib="$(get_size_mib "$esp_image")"
boot_size_mib="$(get_size_mib "$boot_image")"

if ! command -v sfdisk >/dev/null; then
    echo "sfdisk not found; please install it to partition the device" >&2
    exit 1
fi

write_partition_table() {
    if sfdisk --help 2>/dev/null | grep -q -- '--unit'; then
        if sfdisk --label dos --unit MiB "$device" <<EOF
1 : start=1, size=$esp_size_mib, type=0x0c, bootable
2 : size=$boot_size_mib, type=0x83
3 : type=0x83
EOF
        then
            return 0
        fi
    fi

    if sfdisk -h 2>/dev/null | grep -q -- '-u'; then
        if sfdisk -uM "$device" <<EOF
1 : start=1, size=$esp_size_mib, type=0x0c, bootable
2 : size=$boot_size_mib, type=0x83
3 : type=0x83
EOF
        then
            return 0
        fi
    fi

    start_sectors=2048
    esp_sectors=$((esp_size_mib * 2048))
    boot_sectors=$((boot_size_mib * 2048))
    sfdisk "$device" <<EOF
$start_sectors,$esp_sectors,0x0c,*
,$boot_sectors,0x83
,,0x83
EOF
}

echo "Writing partition table to $device"
write_partition_table

sync
if command -v partprobe >/dev/null; then
    partprobe "$device" || true
fi
if command -v udevadm >/dev/null; then
    udevadm settle
else
    sleep 2
fi

case "$device" in
    *[0-9]) part_prefix="${device}p" ;;
    *) part_prefix="${device}" ;;
esac

part1="${part_prefix}1"
part2="${part_prefix}2"
part3="${part_prefix}3"

for part in "$part1" "$part2" "$part3"; do
    i=0
    while [ "$i" -lt 20 ]; do
        [ -b "$part" ] && break
        sleep 1
        i=$((i + 1))
    done
    if [ ! -b "$part" ]; then
        echo "Partition not found: $part" >&2
        exit 1
    fi
done

echo "Writing U-Boot to $device"
dd if="$uboot_bin" of="$device" bs=1024 seek=8 conv=fsync,notrunc status=progress

echo "Flashing partitions"
dd if="$esp_image" of="$part1" bs=4M conv=fsync status=progress
dd if="$boot_image" of="$part2" bs=4M conv=fsync status=progress
dd if="$rootfs_image" of="$part3" bs=4M conv=fsync status=progress
sync

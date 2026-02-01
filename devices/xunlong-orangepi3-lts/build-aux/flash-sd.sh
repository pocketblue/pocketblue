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
    echo "sfdisk not found; please install util-linux (sfdisk >= 2.26 for GPT)" >&2
    exit 1
fi

GPT_TYPE_ESP="C12A7328-F81F-11D2-BA4B-00A0C93EC93B"
GPT_TYPE_LINUX_FS="0FC63DAF-8483-4772-8E79-3D69D8477DE4"

UBOOT_DD_BS="${UBOOT_DD_BS:-1024}"
UBOOT_DD_SEEK="${UBOOT_DD_SEEK:-8}"

GPT_TABLE_LENGTH="${GPT_TABLE_LENGTH:-56}"

write_partition_table() {
    local label_id
    label_id="$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid)"

    if sfdisk --help 2>/dev/null | grep -q -- '--wipe'; then
        sfdisk --wipe always --wipe-partitions always "$device" <<EOF
label: gpt
label-id: $label_id
table-length: $GPT_TABLE_LENGTH

1 : start=1MiB,  size=${esp_size_mib}MiB,  type=$GPT_TYPE_ESP,      name="esp"
2 :             size=${boot_size_mib}MiB, type=$GPT_TYPE_LINUX_FS, name="boot"
3 :                                  type=$GPT_TYPE_LINUX_FS,     name="rootfs"
EOF
    else
        sfdisk "$device" <<EOF
label: gpt
label-id: $label_id
table-length: $GPT_TABLE_LENGTH

1 : start=1MiB,  size=${esp_size_mib}MiB,  type=$GPT_TYPE_ESP,      name="esp"
2 :             size=${boot_size_mib}MiB, type=$GPT_TYPE_LINUX_FS, name="boot"
3 :                                  type=$GPT_TYPE_LINUX_FS,     name="rootfs"
EOF
    fi
}

echo "Writing GPT partition table to $device"
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

echo "Writing U-Boot to $device (bs=$UBOOT_DD_BS seek=$UBOOT_DD_SEEK)"
dd if="$uboot_bin" of="$device" bs="$UBOOT_DD_BS" seek="$UBOOT_DD_SEEK" conv=fsync,notrunc status=progress

echo "Flashing partitions"
dd if="$esp_image"    of="$part1" bs=4M conv=fsync status=progress
dd if="$boot_image"   of="$part2" bs=4M conv=fsync status=progress
dd if="$rootfs_image" of="$part3" bs=4M conv=fsync status=progress
sync


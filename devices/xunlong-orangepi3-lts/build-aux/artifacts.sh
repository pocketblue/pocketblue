#!/usr/bin/env bash

set -uexo pipefail

SCRIPT_DIR="$(dirname "$0")"

uboot_bin="/tmp/u-boot-sunxi-with-spl.bin"
disk_raw="$OUT_PATH/disk.raw"

podman run --rm -i quay.io/fedora/fedora-minimal:latest \
    bash -s < "$SCRIPT_DIR/extract-uboot.sh" > "$uboot_bin"

sgdisk --resize-table 56 "$disk_raw"
start_lba=16
ss=512
start_bytes=$(( start_lba * ss ))
dd if="$uboot_bin" of="$disk_raw" bs=4K oflag=seek_bytes seek="$start_bytes" conv=notrunc

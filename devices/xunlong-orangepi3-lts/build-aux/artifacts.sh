#!/usr/bin/env bash

set -uexo pipefail

uboot_deb="$OUT_PATH/linux-u-boot-orangepi3-lts-current.deb"
if [ -f "$uboot_deb" ]; then
    tmp_dir="$(mktemp -d)"
    7z x -o"$tmp_dir" "$uboot_deb"
    data_tar="$(find "$tmp_dir" -maxdepth 1 -name 'data.tar.*' -print -quit)"
    7z x -o"$tmp_dir/data" "$data_tar"
    if [ -f "$tmp_dir/data/data.tar" ]; then
        7z x -o"$tmp_dir/data" "$tmp_dir/data/data.tar"
    fi
    uboot_bin="$(find "$tmp_dir/data" -name 'u-boot-sunxi-with-spl.bin' -print -quit)"
    if [ -z "$uboot_bin" ]; then
        echo "u-boot-sunxi-with-spl.bin not found in $uboot_deb"
        exit 1
    fi
    if [ -f "$OUT_PATH/disk.raw" ]; then
        if [ -f "$OUT_PATH/sgdisk" ]; then
            chmod +x "$OUT_PATH/sgdisk"
            "$OUT_PATH/sgdisk" --resize-table 56 "$OUT_PATH/disk.raw"
            rm -f "$OUT_PATH/sgdisk"
        fi
        start_lba=16
        ss=512
        start_bytes=$(( start_lba * ss ))
        dd if="$uboot_bin" of="$OUT_PATH/disk.raw" oflag=seek_bytes seek="$start_bytes" conv=notrunc
    fi
    rm -r "$tmp_dir"
    rm -r "$uboot_deb"
fi

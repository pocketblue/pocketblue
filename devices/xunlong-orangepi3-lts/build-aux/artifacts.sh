#!/usr/bin/env bash

set -uexo pipefail

uboot_deb="$OUT_PATH/linux-u-boot-orangepi3-lts-current.deb"
if [ -f "$uboot_deb" ]; then
    tmp_dir="$(mktemp -d)"
    ar x --output="$tmp_dir" "$uboot_deb"
    data_tar="$(find "$tmp_dir" -maxdepth 1 -name 'data.tar.*' -print -quit)"
    mkdir -p "$tmp_dir/data"
    tar -xf "$data_tar" -C "$tmp_dir/data"
    uboot_bin="$(find "$tmp_dir/data" -name 'u-boot-sunxi-with-spl.bin' -print -quit)"
    if [ -z "$uboot_bin" ]; then
        echo "u-boot-sunxi-with-spl.bin not found in $uboot_deb" >&2
        exit 1
    fi
    cp "$uboot_bin" "$OUT_PATH/images/u-boot-sunxi-with-spl.bin"
    dd if="$uboot_bin" of="$OUT_PATH/images/disk.raw" bs=1024 seek=8 conv=notrunc
    rm -r "$tmp_dir"
fi

install -Dm 0755 "$DEVICE_PATH/build-aux/flash-sd.sh" "$OUT_PATH/flash-orangepi3-lts.sh"

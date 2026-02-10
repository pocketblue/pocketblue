#!/usr/bin/env bash

set -uexo pipefail

uboot_bin="$OUT_PATH/u-boot-sunxi-with-spl.bin"

dnf -y install bsdtar 'dnf5-command(copr)'
dnf -y copr enable ergolyam/rpms-orangepi3-lts
dnf download --repo=copr:copr.fedorainfracloud.org:ergolyam:rpms-orangepi3-lts --destdir=$OUT_PATH u-boot
bsdtar -xOf $OUT_PATH/u-boot-*.rpm '*/u-boot-sunxi-with-spl.bin' > $uboot_bin

if [ -f "$uboot_bin" ]; then
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
fi

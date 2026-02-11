#!/usr/bin/env bash

set -uexo pipefail

uboot_bin="$OUT_PATH/u-boot-sunxi-with-spl.bin"

podman run --rm quay.io/fedora/fedora-minimal:latest \
    bash -uexo pipefail -c "exec 3>&1 1>&2
        dnf -y install bsdtar 'dnf5-command(copr)'
        dnf -y copr enable ergolyam/rpms-orangepi3-lts
        dnf download --repo=copr:copr.fedorainfracloud.org:ergolyam:rpms-orangepi3-lts --destdir=/tmp u-boot
        1>&3 bsdtar -xOf /tmp/u-boot-*.aarch64.rpm '*/u-boot-sunxi-with-spl.bin'
    " > $uboot_bin

sgdisk --resize-table 56 "$OUT_PATH/disk.raw"
start_lba=16
ss=512
start_bytes=$(( start_lba * ss ))
dd if="$uboot_bin" of="$OUT_PATH/disk.raw" oflag=seek_bytes seek="$start_bytes" conv=notrunc

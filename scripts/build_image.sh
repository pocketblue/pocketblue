#!/usr/bin/env bash

set -uexo pipefail

which 7z
which kpartx

mkdir artifacts

sudo kpartx -vafs "./$OUTPUT_DIR/image/disk.raw"
sudo dd if=/dev/mapper/loop0p1 of=efipart.vfat bs=1M
sudo dd if=/dev/mapper/loop0p2 of=artifacts/boot.raw bs=1M
sudo dd if=/dev/mapper/loop0p3 of=artifacts/root.raw bs=1M

VOLID=$(file efipart.vfat | grep -Eo "serial number 0x.{8}" | cut -d' ' -f3)

truncate -s $ESP_SIZE artifacts/esp.raw
mkfs.vfat -F 32 -S 4096 -n EFI -i $VOLID artifacts/esp.raw

mkdir -p esp.old esp.new
sudo mount -o loop efipart.vfat esp.old
sudo mount -o loop artifacts/esp.raw esp.new

sudo cp -a esp.old/. esp.new/
sudo umount esp.old/ esp.new/
sudo chmod 666 artifacts/*

dd if=/dev/zero bs=1 count=512 | tee -a artifacts/root.raw

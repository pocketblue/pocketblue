#!/usr/bin/env bash

set -uexo pipefail

export UUID=$(blkid -s UUID -o value /dev/mapper/loop0p1 | tr -d '-')

truncate -s $CONF_ESP_SIZE images/fedora_esp.raw
mkfs.vfat -F 32 -S $CONF_ESP_SECTOR_SIZE -n EFI -i $UUID images/fedora_esp.raw

mkdir -p esp.old esp.new
mount /dev/mapper/loop0p1 esp.old
mount -o loop images/fedora_esp.raw esp.new
cp -a esp.old/. esp.new/
umount esp.old esp.new
rmdir esp.old esp.new

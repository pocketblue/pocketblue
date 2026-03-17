#!/usr/bin/env bash

set -uexo pipefail

esp_dev=/dev/mapper/loop0p1
export UUID=$(blkid -s UUID -o value "$esp_dev" | tr -d '-')

tmp_dir="$(mktemp -d)"
mkdir -p "$tmp_dir/esp.old" "$tmp_dir/esp.new"

mount "$esp_dev" "$tmp_dir/esp.old"
cp -a "$tmp_dir/esp.old/." "$tmp_dir/esp.new/"
umount "$tmp_dir/esp.old"

mkfs.vfat -F 32 -S "$CONF_ESP_SECTOR_SIZE" -n EFI -i "$UUID" "$esp_dev"

mount "$esp_dev" "$tmp_dir/esp.old"
cp -a "$tmp_dir/esp.new/." "$tmp_dir/esp.old/"
umount "$tmp_dir/esp.old"

rm -r "$tmp_dir"

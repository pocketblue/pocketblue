#!/usr/bin/env bash

set -uexo pipefail

mkdir boot
mount -o loop images/fedora_boot.raw boot
mount -o loop images/fedora_esp.raw boot/efi
cp -ar boot/ostree/default-*/dtb boot/efi/dtb
umount -R boot/
rmdir boot

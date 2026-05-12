#!/usr/bin/env bash

set -uexo pipefail

kpartx -vafs $FULL_IMAGE/image/disk.raw

# fedora_esp.raw always should be rebuilt
bash $ACTION_PATH/rebuild-fedora-esp.sh

# fedora_boot.raw
if [ $CONF_BOOT_SIZE = 1024M ]; then
    # 1024M is the default, no need to rebuild image
    dd if=/dev/mapper/loop0p2 of=images/fedora_boot.raw bs=1M
else
    # to get non-default image size we should rebuild it
    bash $ACTION_PATH/rebuild-fedora-boot.sh
fi

# fedora_rootfs.raw, no need to rebuild image
dd if=/dev/mapper/loop0p3 of=images/fedora_rootfs.raw bs=1M

# pad the last block to 4096 bytes
dd if=/dev/zero bs=1 count=512 | tee -a images/fedora_rootfs.raw

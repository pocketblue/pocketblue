#!/usr/bin/env bash

set -uexo pipefail

if ls $OUTPUT/fedora_*.raw 1> /dev/null 2>&1; then
    mkdir -p $OUTPUT/images

    # remove the leftover whole disk image
    rm $OUTPUT/disk.raw

    # keep the extras
    mv $OUTPUT/fedora_*.raw $OUTPUT/images/

    # setup loop devices
    export esp_part=$(losetup --find --show $OUTPUT/images/fedora_esp.raw)
    trap "losetup -d $esp_part" EXIT # in case the next `losetup` fails
    export root_part=$(losetup --find --show $OUTPUT/images/fedora_rootfs.raw)
    trap "losetup -d $esp_part && losetup -d $root_part" EXIT
else
    chmod 666 $OUTPUT/disk.raw

    # setup loop devices
    loop=$(losetup --find --show --partscan --sector-size 4096 $OUTPUT/disk.raw)
    trap "losetup -d $loop" EXIT
    export esp_part="${loop}p1"
    export root_part="${loop}p2"
fi

[ "$CONF_INSTALL_DTB" = "true" ] && $SCRIPTS/install-dtb.sh
[ "$CONF_BUILD_EROFS" = "true" ] && $SCRIPTS/build-erofs.sh

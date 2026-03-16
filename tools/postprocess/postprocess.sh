#!/usr/bin/env bash

set -uexo pipefail

if [ "$CONF_SPLIT_PARTITIONS" = "true" ]; then
    mkdir images
    $ACTION_PATH/split-partitions.sh
    [ "$CONF_INSTALL_DTB" = "true" ] && $ACTION_PATH/install-dtb.sh
    [ "$CONF_BUILD_EROFS" = "true" ] && $ACTION_PATH/build-erofs.sh
    chmod 666 images/*
else
    kpartx -vafs $FULL_IMAGE/image/disk.raw
    $ACTION_PATH/rebuild-esp-inplace.sh
    kpartx -d $FULL_IMAGE/image/disk.raw
    cp $FULL_IMAGE/image/disk.raw ./disk.raw
    chmod 666 disk.raw
fi

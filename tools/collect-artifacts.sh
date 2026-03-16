#!/usr/bin/env bash

set -uexo pipefail

which 7z

mkdir out
if [ -d images ]; then
    mv images out/
fi
if [ -f disk.raw ]; then
    mv disk.raw out/
fi

# extra downloads
if [ -f "$DEVICE_PATH/$BUILD_AUX/extra-sources" ]; then
    $ACTION_PATH/download-extra.sh $DEVICE_PATH/$BUILD_AUX/extra-sources
fi

# custom artifact processing script
export OUT_PATH=$(realpath ./out)
export DEVICE_PATH=$(realpath $DEVICE_PATH)
$DEVICE_PATH/$BUILD_AUX/artifacts.sh

# pack the artifacts:

if [ -f "rootfs.ero" ]; then
    mv "rootfs.ero" "rootfs-$IMAGE_NAME-$IMAGE_TAG.ero"
fi

cd out
7z a -mx=9 $ARGS_7Z "../pocketblue-$IMAGE_NAME-$IMAGE_TAG.7z" .

#!/usr/bin/env bash

set -uexo pipefail

which mkfs.erofs

ROOTFS_TAR=rootfs.tar
ROOTFS_EXTRACT=pocketblue-rootfs
ROOTFS_ERO=rootfs.ero

CTR="$(podman create --rm $OCI_IMAGE /usr/bin/bash)"
podman export "$CTR" > $ROOTFS_TAR

mkdir $ROOTFS_EXTRACT
tar --xattrs-include='*' -p -xf $ROOTFS_TAR -C $ROOTFS_EXTRACT
rm $ROOTFS_TAR

mkfs.erofs -zlz4 -C1048576 $ROOTFS_ERO $ROOTFS_EXTRACT
rm -rf $ROOTFS_EXTRACT

chown "$(id -u):$(id -g)" $ROOTFS_ERO

#!/usr/bin/env bash

set -uexo pipefail

exec 3>&1 1>&2

dnf -y install bsdtar 'dnf5-command(copr)'
dnf -y copr enable ergolyam/rpms-orangepi3-lts
dnf download --repo=copr:copr.fedorainfracloud.org:ergolyam:rpms-orangepi3-lts --destdir=/tmp u-boot

1>&3 bsdtar -xOf /tmp/u-boot-*.aarch64.rpm '*/u-boot-sunxi-with-spl.bin'

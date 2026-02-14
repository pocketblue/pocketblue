#!/usr/bin/env bash

set -uexo pipefail

exec 3>&1 1>&2

dnf -y install bsdtar 'dnf5-command(copr)'
dnf -y copr enable pocketblue/sunxi64
dnf download --repo=copr:copr.fedorainfracloud.org:pocketblue:sunxi64 --destdir=/tmp u-boot

1>&3 bsdtar -xOf /tmp/u-boot-*.aarch64.rpm '*/u-boot-sunxi-with-spl.bin'

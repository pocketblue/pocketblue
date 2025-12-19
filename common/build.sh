#!/usr/bin/env bash

set -uexo pipefail

cp -arfT etc /etc
cp -arfT usr /usr

# workaround (see https://github.com/ublue-os/bluefin-lts/issues/3)
mkdir -p /var/roothome

# make /usr/local and /opt directories mutable
rm -rf /usr/local
rm -rf /opt
ln -s /var/usrlocal /usr/local
ln -s /var/opt /opt

# development tools
dnf -y install git just buildah

# only keep the EN langpack to decrease image size
dnf -y swap glibc-all-langpacks glibc-langpack-en

dnf -y remove dracut-config-rescue

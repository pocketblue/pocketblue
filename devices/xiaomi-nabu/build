#!/usr/bin/env bash

set -uexo pipefail

# Files

cp -arfT files/etc /etc

# Packages

dnf -y install \
    xiaomi-nabu-configs \
    xiaomi-nabu-firmware \
    alsa-ucm-conf-sm8150 \
    ath10k-shutdown \
    tqftpserv \
    qbootctl \
    rmtfs \
    qrtr

# Services

systemctl enable \
    tqftpserv.service \
    rmtfs.service \
    qbootctl.service

# Kernel

mkdir -p /boot/dtb
dnf -y remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core
rm -rf /usr/lib/modules/*
dnf -y install kernel
rm -r /boot/dtb

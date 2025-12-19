#!/usr/bin/env bash

set -uexo pipefail

dnf -y remove gnome-shell gdm
dnf -y install phosh phrog

dnf -y install default-flatpaks

dnf -y remove \
    firefox \
    firefox-langpacks

dnf -y remove \
    gnome-classic-session \
    gnome-system-monitor \
    gnome-user-docs \
    gnome-tour \
    malcontent-control \
    yelp

systemctl enable --force phrog.service

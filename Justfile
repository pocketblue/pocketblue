set dotenv-load

silverblue := env("PB_SILVERBLUE", "quay.io/fedora/fedora-silverblue")
kinoite := env("PB_KINOITE", "quay.io/fedora/fedora-kinoite")
base_atomic := env("PB_BASE_ATOMIC", "quay.io/fedora-ostree-desktops/base-atomic")

branch := env("PB_BRANCH", "43")
tag := env("PB_TAG", branch)

device := env("PB_DEVICE", "qualcomm-sdm845")
desktop := env("PB_DESKTOP", "phosh")

base := env("PB_BASE",
    if desktop == "gnome-desktop" {
        silverblue
    } else if desktop == "gnome-mobile" {
        silverblue
    } else if desktop == "phosh" {
        silverblue
    } else if desktop == "plasma-desktop" {
        kinoite
    } else if desktop == "plasma-mobile" {
        kinoite
    } else {
        base_atomic
    }
)

base_bootc := env("PB_BASE_BOOTC", "quay.io/fedora/fedora-bootc:" + branch)

registry := env("PB_REGISTRY", "localhost")

expires_after := env("PB_EXPIRES_AFTER", "")
rechunk_suffix := env("PB_RECHUNK_SUFFIX", "-build")
arch := env("PB_ARCH", "arm64")

# disk image vars
bib_config := env("PB_BIB_CONFIG", "./bootc-image-builder.toml")
bib_output := env("PB_BIB_CONFIG", "./output")
bib := env("PB_BIB", "quay.io/centos-bootc/bootc-image-builder:latest")
disk_type := env("PB_DISK_TYPE", "raw")
rootfs := env("PB_ROOTFS", "btrfs")

import "tools/containers.just"
import "tools/disk_images.just"

default: build

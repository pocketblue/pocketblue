set dotenv-load

import "tools/recipes/core.just"
import "tools/recipes/qemu.just"


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
rootfs := env("PB_ROOTFS", "btrfs")
qemu_cpu := env("PB_QEMU_CPU", "cortex-a76")

image := registry + "/" + device + "-" + desktop + ":" + tag
d_type := env("PB_D_TYPE", "qcow2")



clean:
    rm -rf output/

clean-all:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Cleaning disk images..."
    rm -rf output/
    echo "Cleaning container images..."
    sudo buildah rmi --all 2>/dev/null || true
    echo "Done."


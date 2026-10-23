set dotenv-load

silverblue := env("PB_SILVERBLUE", "quay.io/fedora/fedora-silverblue")
kinoite := env("PB_KINOITE", "quay.io/fedora/fedora-kinoite")
base_atomic := env("PB_BASE_ATOMIC", "quay.io/fedora-ostree-desktops/base-atomic")

branch := env("PB_BRANCH", "44")
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
) + ":" + branch

registry := env("PB_REGISTRY", "localhost")

fallback_image := env("PB_FALLBACK_IMAGE", registry / device + "-" + desktop + ":" + branch)
full_image := env("PB_FULL_IMAGE", registry / device + "-" + desktop + ":" + tag)

expires_after := env("PB_EXPIRES_AFTER", "")
rechunk_suffix := env("PB_RECHUNK_SUFFIX", "-build")
arch := env("PB_ARCH", "arm64")

# disk image vars
compression_7z := env("PB_COMPRESSION_7Z", "") # 7z compression args, empty means default compression
variant := env("PB_VARIANT", "default")

import "tools/containers.just"
import "tools/disk_images.just"

default: build

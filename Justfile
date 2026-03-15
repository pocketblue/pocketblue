set dotenv-load

import 'tools/build.just'
import 'tools/pull.just'
import 'tools/rechunk.just'
import 'tools/rebase.just'
import 'tools/bootc.just'

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

default: build

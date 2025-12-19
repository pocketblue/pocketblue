silverblue := "quay.io/fedora/fedora-silverblue"
kinoite := "quay.io/fedora/fedora-silverblue"
base_atomic := "quay.io/fedora-ostree-desktops/base-atomic"

branch := "43"
tag := branch

device := "oneplus-sdm845"
desktop := "phosh"

base := if desktop == "gnome-desktop" {
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

base_bootc := "quay.io/fedora/fedora-bootc:" + branch

expires_after := ""
rechunk_suffix := ""
arch := "arm64"

build:
    sudo buildah bud \
        --arch="{{arch}}" \
        --build-arg "base={{base}}:{{branch}}" \
        --build-arg "device={{device}}" \
        --build-arg "desktop={{desktop}}" \
        --build-arg "target_tag={{tag}}" \
        -t "{{device}}-{{desktop}}:{{tag}}{{rechunk_suffix}}" \
        {{ if expires_after != "" { "--label quay.expires-after=" + expires_after } else { "" } }} \
        "."

rechunk image target:
    sudo podman run --rm --privileged -v /var/lib/containers:/var/lib/containers \
        {{base_bootc}} \
        /usr/libexec/bootc-base-imagectl rechunk \
        {{image}} \
        {{target}}

rebase local_image:
    sudo rpm-ostree rebase ostree-unverified-image:containers-storage:{{local_image}}

silverblue := "quay.io/fedora/fedora-silverblue"
kinoite := "quay.io/fedora/fedora-kinoite"
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

registry := "localhost"

expires_after := ""
rechunk_suffix := ""
arch := "arm64"

pull:
    sudo podman pull {{base}}:{{branch}}
    sudo podman pull {{base_bootc}}
    sudo podman pull {{registry}}/{{device}}-{{desktop}}:{{tag}} || true

build *ARGS:
    sudo buildah bud \
        --arch="{{arch}}" \
        --build-arg "base={{base}}:{{branch}}" \
        --build-arg "device={{device}}" \
        --build-arg "desktop={{desktop}}" \
        --build-arg "target_tag={{tag}}" \
        {{ARGS}} \
        -t "{{registry}}/{{device}}-{{desktop}}:{{tag}}{{rechunk_suffix}}" \
        {{ if expires_after != "" { "--label quay.expires-after=" + expires_after } else { "" } }} \
        "."

rechunk *ARGS:
    sudo podman run --rm --privileged -v /var/lib/containers:/var/lib/containers {{ARGS}} \
        {{base_bootc}} \
        /usr/libexec/bootc-base-imagectl rechunk \
        {{registry}}/{{device}}-{{desktop}}:{{tag}}{{rechunk_suffix}} \
        {{registry}}/{{device}}-{{desktop}}:{{tag}}

rebase local_image=(registry / device + "-" + desktop + ":" + tag):
    sudo rpm-ostree rebase ostree-unverified-image:containers-storage:{{local_image}}

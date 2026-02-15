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
rechunk_suffix := env("PB_RECHUNK_SUFFIX", "")
arch := env("PB_ARCH", "arm64")

default: build

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

bootc *ARGS:
    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /sys/fs/selinux:/sys/fs/selinux \
        -v /etc/containers:/etc/containers:Z \
        -v /var/lib/containers:/var/lib/containers:Z \
        -v /dev:/dev \
        -e RUST_LOG=debug \
        -v .:/data \
        --security-opt label=type:unconfined_t \
        "{{registry}}/{{device}}-{{desktop}}:{{tag}}" bootc {{ARGS}}

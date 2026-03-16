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

full_image := env("PB_FULL_IMAGE", registry / device + "-" + desktop + ":" + tag)

expires_after := env("PB_EXPIRES_AFTER", "")
rechunk_suffix := env("PB_RECHUNK_SUFFIX", "-build")
arch := env("PB_ARCH", "arm64")

# disk image vars
bib_config := env("PB_BIB_CONFIG", "./bootc-image-builder.toml")
bib_output := env("PB_BIB_CONFIG", "./output")
bib := env("PB_BIB", "quay.io/centos-bootc/bootc-image-builder:latest")
disk_type := env("PB_DISK_TYPE", "raw")
rootfs := env("PB_ROOTFS", "btrfs")

default: build

pull:
    sudo podman pull {{base}}
    sudo podman pull {{full_image}} || true

build *ARGS:
    sudo buildah bud \
        --layers=true \
        --arch="{{arch}}" \
        --build-arg="base={{base}}" \
        --build-arg="device={{device}}" \
        --build-arg="desktop={{desktop}}" \
        --build-arg="target_tag={{tag}}" \
        {{ARGS}} \
        -t "{{full_image}}{{rechunk_suffix}}" \
        {{ if expires_after != "" { "--label quay.expires-after=" + expires_after } else { "" } }} \
        "."

rechunk *ARGS:
    sudo podman run --rm --privileged -v /var/lib/containers:/var/lib/containers {{ARGS}} \
        {{base}} \
        rpm-ostree experimental compose build-chunked-oci \
            --bootc \
            --format-version=1 \
            --from={{full_image}}{{rechunk_suffix}} \
            --output=containers-storage:{{full_image}}

sign digest:
    cosign sign -y --new-bundle-format=false --key env://SIGNING_KEY "{{registry}}/{{device}}-{{desktop}}@{{digest}}"

rebase:
    sudo rpm-ostree rebase ostree-unverified-image:containers-storage:{{full_image}}

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
        "{{full_image}}" bootc {{ARGS}}

disk:
    sudo mkdir -p {{bib_output}}
    sudo podman run \
        --rm -it --privileged \
        --security-opt label=type:unconfined_t \
        -v {{bib_config}}:/config.toml:ro \
        -v {{bib_output}}:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        {{bib}} \
            --use-librepo=True \
            --type={{disk_type}} \
            --rootfs={{rootfs}} \
            --output={{bib_output}} \
            {{full_image}}

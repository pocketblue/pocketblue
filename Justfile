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
rootfs := env("PB_ROOTFS", "btrfs")
qemu_cpu := env("PB_QEMU_CPU", "cortex-a76")

# Detect container runtime
_runtime := if `command -v podman >/dev/null 2>&1; echo $?` == "0" { "podman" } else if `command -v docker >/dev/null 2>&1; echo $?` == "0" { "docker" } else { "" }

_check_runtime:
    #!/usr/bin/env bash
    if [ -z "{{_runtime}}" ]; then
        echo "error: need podman or docker to run this target" >&2
        exit 1
    fi

default: build

pull:
    sudo podman pull {{base}}:{{branch}}
    sudo podman pull {{base_bootc}}
    sudo podman pull {{registry}}/{{device}}-{{desktop}}:{{tag}} || true

[default]
build *ARGS:
    sudo buildah bud \
        --net=host \
        --arch="{{arch}}" \
        --build-arg "base={{base}}:{{branch}}" \
        --build-arg "device={{device}}" \
        --build-arg "desktop={{desktop}}" \
        --build-arg "target_tag={{tag}}" \
        {{ARGS}} \
        -t "{{registry}}/{{device}}-{{desktop}}:{{tag}}{{rechunk_suffix}}" \
        {{ if expires_after != "" { "--label quay.expires-after=" + expires_after } else { "" } }} \
        "."

rechunk *ARGS: _check_runtime
    sudo {{_runtime}} run --rm --privileged -v /var/lib/containers:/var/lib/containers {{ARGS}} \
        {{base_bootc}} \
        /usr/libexec/bootc-base-imagectl rechunk \
        {{registry}}/{{device}}-{{desktop}}:{{tag}}{{rechunk_suffix}} \
        {{registry}}/{{device}}-{{desktop}}:{{tag}}

rebase local_image=(registry / device + "-" + desktop + ":" + tag):
    sudo rpm-ostree rebase ostree-unverified-image:containers-storage:{{local_image}}

bootc *ARGS: _check_runtime
    sudo {{_runtime}} run \
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

disk image="" type="qcow2" rootfs_override="": _check_runtime
    #!/usr/bin/env bash
    set -euo pipefail
    IMAGE="{{image}}"
    TYPE="{{type}}"
    ROOTFS="{{rootfs_override}}"
    if [ -z "$IMAGE" ]; then
        echo "error: image parameter required" >&2; exit 1
    fi
    # Use global rootfs if override not provided
    if [ -z "$ROOTFS" ]; then
        ROOTFS="{{rootfs}}"
    fi
    echo "==> producing $TYPE disk image from $IMAGE via bootc-image-builder (rootfs: $ROOTFS)"
    mkdir -p output
    sudo {{_runtime}} run \
        --rm --privileged \
        --pull=newer \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v "$(pwd)/bootc-image-builder.toml":/config.toml:ro \
        -v "$(pwd)/output":/output \
        --security-opt label=type:unconfined_t \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type="$TYPE" \
        --target-arch="{{arch}}" \
        --rootfs="$ROOTFS" \
        "$IMAGE"
    sudo chown -R "$(id -u):$(id -g)" output
    echo "==> disk image ready: output/$TYPE/"

build-qemu qemu_device="qemu" qemu_desktop="tty" image="" type="qcow2":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -z "{{image}}" ]; then
        IMAGE="{{registry}}/{{qemu_device}}-{{qemu_desktop}}:{{tag}}"
        echo "==> building container image: $IMAGE"
        just device={{qemu_device}} desktop={{qemu_desktop}} build
    else
        IMAGE="{{image}}"
    fi
    # Use ext4 for QEMU disk images (btrfs kernel ioctl not supported in container)
    just disk "$IMAGE" "{{type}}" "ext4"

qemu path="output/qcow2/disk.qcow2" memory="4096":
    # run QEMU on a disk image (produced by build-qemu or the images workflow).
    test -f {{path}} || { echo "disk image not found: {{path}} \nRun 'just build-qemu' first"; exit 1; }
    QEMU_CPU={{qemu_cpu}} ./tools/run-qemu.sh {{path}} {{memory}}

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


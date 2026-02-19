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

default: build

pull:
    sudo podman pull {{base}}:{{branch}}
    sudo podman pull {{base_bootc}}
    sudo podman pull {{registry}}/{{device}}-{{desktop}}:{{tag}} || true

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

build-qemu qemu_device="qemu" qemu_desktop="tty" image="" type="qcow2":
    #!/usr/bin/env bash
    set -euo pipefail
    IMAGE="{{image}}"
    if [ -z "$IMAGE" ]; then
        IMAGE="{{registry}}/{{qemu_device}}-{{qemu_desktop}}:{{tag}}"
        echo "==> building container image: $IMAGE"
        just device={{qemu_device}} desktop={{qemu_desktop}} build
    fi
    echo "==> producing {{type}} disk image from $IMAGE via bootc-image-builder"
    mkdir -p output
    # bootc-image-builder reads the source container image from
    # containers-storage
    # Run BIB itself with whatever container runtime is available.
    if command -v podman >/dev/null 2>&1; then
        RUNTIME="sudo podman"
    elif command -v docker >/dev/null 2>&1; then
        RUNTIME="sudo docker"
    else
        echo "need podman or docker to run bootc-image-builder" >&2; exit 1
    fi
    # RFC: Can we do --user yet?
    $RUNTIME run \
        --rm --privileged \
        --pull=newer \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v "$(pwd)/bootc-image-builder.toml":/config.toml:ro \
        -v "$(pwd)/output":/output \
        --security-opt label=type:unconfined_t \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type {{type}} \
        --target-arch {{arch}} \
        --rootfs ext4 \
        "$IMAGE"
    # fix permissions: BIB runs as root, output needs to be readable by the user
    # Try not to fall asleep - sudo expires and build halts :)
    sudo chown -R "$(id -u):$(id -g)" output
    echo "==> disk image ready: output/{{type}}/"

qemu path="output/qcow2/disk.qcow2":
    # run QEMU on a disk image (produced by build-qemu or the images workflow).
    test -f {{path}} || { echo "disk image not found: {{path}} \nRun 'just build-qemu' first"; exit 1; }
    ./tools/run-qemu.sh {{path}}

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


[private]
pull-base:
    sudo podman pull {{base}}

[private]
pull-image:
    sudo podman pull {{full_image}} || true

[parallel]
pull: pull-base pull-image

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
            --max-layers=127 \
            --from={{full_image}}{{rechunk_suffix}} \
            --output=containers-storage:{{full_image}}

build-chunkah *ARGS:
    buildah bud \
        --layers=true \
        --skip-unused-stages=false \
        --arch="{{arch}}" \
        --build-arg="base={{base}}" \
        --build-arg="device={{device}}" \
        --build-arg="desktop={{desktop}}" \
        --build-arg="target_tag={{tag}}" \
        --build-arg="CHUNKAH_CONFIG_STR=$(podman inspect {{full_image}})" \
        -v=$(pwd):/run/src \
        --security-opt=label=disable \
        {{ if expires_after != "" { "--label quay.expires-after=" + expires_after } else { "" } }} \
        {{ARGS}} \
        -t "{{full_image}}" \
        -f Containerfile.chunkah.in \
        "."
    [ -d out ] && rm -r out/

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

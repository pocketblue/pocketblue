# Main recipes for building and running Pocketblue images.

default: build


disk d_type="qcow2" rootfs="":
    bash ./tools/recipes/bin/disk.sh "{{image}}" "{{d_type}}" "{{rootfs}}"

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

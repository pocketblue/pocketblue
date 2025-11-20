branch := "42"
tag := branch
base_image := "quay.io/fedora/fedora-bootc:" + branch
arch := "arm64"
expires_after := ""

build from target context:
    #!/usr/bin/env bash
    set -euxo pipefail

    # Take the part after ':' as a tag
    target_tag=$(echo {{target}} | sed 's/.*://')
    [[ "{{target}}" != "$target_tag" ]] || false

    sudo buildah bud \
        --arch="{{arch}}" \
        --build-arg "from={{from}}" \
        --build-arg "target_tag=${target_tag}" \
        -t "{{target}}" \
        {{ if expires_after != "" { "--label quay.expires-after=" + expires_after } else { "" } }} \
        "{{context}}"

build-base \
    from=base_image \
    target=("base:" + tag): \
    (build from target "base")

build-device \
    device \
    from=("localhost/base:" + tag) \
    target=(device + "-base:" + tag): \
    (build from target "devices"/device/"container")

build-desktop \
    device \
    desktop \
    from=("localhost/" + device + "-base:" + tag) \
    target=(device + "-" + desktop + ":" + tag): \
    (build from target "desktops"/desktop)

rechunk image target:
    sudo podman run --rm --privileged -v /var/lib/containers:/var/lib/containers \
        {{base_image}} \
        /usr/libexec/bootc-base-imagectl rechunk \
        {{image}} \
        {{target}}

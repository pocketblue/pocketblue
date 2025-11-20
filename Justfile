branch := "42"
tag := branch
base_image := "quay.io/fedora/fedora-bootc:" + branch

build from target context expires="false":
    #!/usr/bin/env bash
    set -euxo pipefail

    # Take the part after ':' as a tag
    target_tag=$(echo {{target}} | sed 's/.*://')
    [[ "{{target}}" != "$target_tag" ]] || false

    sudo buildah bud \
        --arch=arm64 \
        --build-arg "from={{from}}" \
        --build-arg "target_tag=${target_tag}" \
        -t "{{target}}" \
        {{ if expires == "true" { "--label quay.expires-after=1w" } else { "" } }} \
        "{{context}}"

build-base \
    from=base_image \
    target=("base:" + tag) \
    expires="false": \
    (build from target "base" expires)

build-device \
    device \
    from=("base:" + tag) \
    target=(device + "-base:" + tag) \
    expires="false": \
    (build from target "devices"/device/"container" expires)

build-desktop \
    device \
    desktop \
    from=(device + "-base:" + tag) \
    target=(device + "-" + desktop + ":" + tag) \
    expires="false": \
    (build from target "desktops"/desktop expires)

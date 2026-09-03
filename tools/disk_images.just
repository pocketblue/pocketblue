disk:
    mkdir -p ./output
    podman run \
        --rm -it --privileged \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        -v ./output:/output \
        -v ./common/blueprint.toml:/blueprint.toml \
        ghcr.io/osbuild/image-builder-cli:latest \
            build \
                --bootc-ref={{full_image}} \
                --blueprint=/blueprint.toml \
                --output-dir=/output \
                --output-name=disk.raw \
                --progress=verbose \
                raw

postprocess:
    #!/usr/bin/env bash
    set -euo pipefail

    source devices/{{device}}/build-aux/device.conf
    export CONF_INSTALL_DTB=${install_dtb:-}
    export CONF_SPLIT_PARTITIONS=${split_partitions:-}
    export CONF_BUILD_EROFS=${build_erofs:-false}

    export OUTPUT=./output
    export SCRIPTS=tools/postprocess
    export OCI_IMAGE="{{full_image}}"

    tools/postprocess/postprocess.sh

artifacts:
    #!/usr/bin/env bash
    set -euo pipefail

    export DEVICE_PATH=devices/{{device}}
    export ARGS_7Z={{compression_7z}}
    export SCRIPTS=tools/postprocess

    tools/collect-artifacts.sh

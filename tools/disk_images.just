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
            "{{registry}}/{{device}}-{{desktop}}:{{tag}}"

postprocess:
    #!/usr/bin/env bash
    set -euo pipefail

    source devices/{{device}}/build-aux/device.conf
    export CONF_ESP_SIZE=${esp_size:-}
    export CONF_ESP_SECTOR_SIZE=${esp_sector_size:-4096}
    export CONF_BOOT_SIZE=${boot_size:-}
    export CONF_INSTALL_DTB=${install_dtb:-}
    export CONF_SPLIT_PARTITIONS=${split_partitions:-}
    export CONF_BUILD_EROFS=${build_erofs:-false}

    export ROOTFS_TYPE={{rootfs}}
    export FULL_IMAGE={{bib_output}}
    export ACTION_PATH=tools/postprocess
    export BUILD_AUX=build-aux
    export OCI_IMAGE="{{registry}}/{{device}}-{{desktop}}:{{tag}}"

    sudo -E tools/postprocess/postprocess.sh

artifacts:
    #!/usr/bin/env bash
    set -euo pipefail

    export DEVICE_PATH=devices/{{device}}
    export ARGS_7Z="{{compression_7z}}"
    export ACTION_PATH=tools/postprocess
    export BUILD_AUX=build-aux

    tools/collect-artifacts.sh

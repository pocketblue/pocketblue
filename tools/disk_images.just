disk image=(registry / device + "-" + desktop + ":" + tag):
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
            {{image}}

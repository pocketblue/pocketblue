rechunk *ARGS:
    sudo podman run --rm --privileged -v /var/lib/containers:/var/lib/containers {{ARGS}} \
        {{base_bootc}} \
        /usr/libexec/bootc-base-imagectl rechunk \
        {{registry}}/{{device}}-{{desktop}}:{{tag}}{{rechunk_suffix}} \
        {{registry}}/{{device}}-{{desktop}}:{{tag}}

ARG base
ARG device
ARG desktop
ARG target_tag

# Context

FROM scratch AS ctx

COPY common /common
COPY devices /devices
COPY desktops /desktops

# Building the image

FROM $base

ARG device
ARG desktop
ARG target_tag

# device-specific args
ARG xiaomi_nabu_samsung_ufs=false

RUN --mount=type=bind,from=ctx,source=/common,target=/ctx/common \
    --mount=type=cache,target=/var/cache \
    env --chdir=/ctx/common ./build && \
    /ctx/common/cleanup

RUN --mount=type=bind,from=ctx,source=/common,target=/ctx/common \
    --mount=type=bind,from=ctx,source=/devices,target=/ctx/devices \
    --mount=type=cache,target=/var/cache \
    env --chdir=/ctx/devices/${device} ./build && \
    /ctx/common/cleanup

RUN --mount=type=bind,from=ctx,source=/common,target=/ctx/common \
    --mount=type=bind,from=ctx,source=/desktops,target=/ctx/desktops \
    --mount=type=cache,target=/var/cache \
    env --chdir=/ctx/desktops/${desktop} ./build && \
    /ctx/common/cleanup

# os-release file
RUN sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Fedora Linux ${target_tag} (${desktop})\"/" /usr/lib/os-release

RUN --mount=type=bind,from=ctx,source=/common,target=/ctx/common \
    /ctx/common/cleanup && \
    /ctx/common/finalize

RUN bootc container lint --no-truncate

ARG base
ARG device
ARG desktop
ARG target_tag

# Context

FROM scratch AS common
COPY common /

FROM scratch AS devices
COPY devices /

FROM scratch AS desktops
COPY desktops /

# Building the image

FROM $base as builder

ARG device
ARG desktop
ARG target_tag

COPY cosign.pub /etc/pki/containers/pocketblue.pub

RUN --mount=type=bind,from=common,source=/,target=/ctx/common \
    --mount=type=cache,target=/var/cache \
    env --chdir=/ctx/common ./build && \
    /ctx/common/cleanup

RUN --mount=type=bind,from=common,source=/,target=/ctx/common \
    --mount=type=bind,from=desktops,source=/,target=/ctx/desktops \
    --mount=type=cache,target=/var/cache \
    env --chdir=/ctx/desktops/${desktop} ./build && \
    /ctx/common/cleanup

RUN --mount=type=bind,from=common,source=/,target=/ctx/common \
    --mount=type=bind,from=devices,source=/,target=/ctx/devices \
    --mount=type=cache,target=/var/cache \
    env --chdir=/ctx/devices/${device} ./build && \
    /ctx/common/cleanup

RUN --mount=type=bind,from=common,source=/,target=/ctx/common \
    /ctx/common/finalize

RUN bootc container lint --no-truncate

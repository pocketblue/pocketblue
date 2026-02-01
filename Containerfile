ARG base
ARG device
ARG desktop
ARG target_tag

# Context

FROM scratch AS ctx

ARG device
ARG desktop

COPY common /common
COPY devices/$device /device
COPY desktops/$desktop /desktop

# Building the image

FROM $base

ARG desktop
ARG target_tag

# device-specific args
ARG xiaomi_nabu_samsung_ufs=false

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,target=/var/lib/dnf \
    --mount=type=cache,target=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    env --chdir=/ctx/common ./build && \
    ostree container commit

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,target=/var/lib/dnf \
    --mount=type=cache,target=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    env --chdir=/ctx/device ./build && \
    ostree container commit

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,target=/var/lib/dnf \
    --mount=type=cache,target=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    env --chdir=/ctx/desktop ./build && \
    ostree container commit

# os-release file
RUN sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Fedora Linux $target_tag ($desktop)\"/" /usr/lib/os-release

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/common/cleanup && \
    /ctx/common/finalize

RUN bootc container lint --no-truncate

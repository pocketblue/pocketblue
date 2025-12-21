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

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    cd /ctx/common && \
    ./build && \
    /ctx/common/cleanup

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    cd /ctx/device && \
    ./build && \
    /ctx/common/cleanup

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    cd /ctx/desktop && \
    ./build && \
    /ctx/common/cleanup

# os-release file
RUN sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Fedora Linux $target_tag ($desktop)\"/" /usr/lib/os-release

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/common/finalize

RUN bootc container lint --no-truncate

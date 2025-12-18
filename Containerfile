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

ARG target_tag

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    pushd /ctx/common && \
    ./build.sh && \
    popd

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    pushd /ctx/device && \
    ./build.sh && \
    popd

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    pushd /ctx/desktop && \
    ./build.sh && \
    popd

# os-release file
RUN sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Fedora Linux $target_tag ($desktop)\"/" /usr/lib/os-release

# cleanup
RUN dnf clean all && rm -rf /var/log/*

RUN bootc container lint --no-truncate

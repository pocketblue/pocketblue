FROM quay.io/fedora/fedora-bootc:rawhide

RUN dnf -y install 'dnf5-command(copr)' && \
    dnf -y copr enable @mobility/sdm845 && \
    dnf -y install kernel-0:6.15.0-0.rc2.15.sdm845.fc43 && \
    dnf clean all && \
    bootc container lint

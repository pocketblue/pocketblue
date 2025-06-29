FROM quay.io/fedora/fedora-bootc:rawhide

COPY etc/ /etc/

RUN dnf -y install 'dnf5-command(copr)' && \
    dnf -y copr enable @mobility/sdm845 && \
    dnf -y copr enable samcday/phrog && \
    dnf -y install kernel-0:6.15.0-0.rc2.15.sdm845.fc43 && \
    dnf -y install @standard --exclude="qemu-user-static" && \
    dnf -y install @hardware-support && \
    dnf -y install bcm283x-firmware && \
    dnf -y install grubby && \
    dnf -y install grub2-efi-aa64 grub2-efi-aa64-modules systemd-oomd-defaults systemd-resolved && \
    dnf -y install fedora-release-mobility && \
    dnf -y install glibc-langpack-en && \
    dnf -y install btrfs-progs udisks2-btrfs && \
    dnf -y install @core @base-graphical @phosh-desktop --exclude selinux-policy-targeted,dracut-config-rescue && \
    dnf -y install bootmac hexagonrpc libssc pd-mapper qrtr rmtfs tqftpserv alsa-ucm-mobility-sdm845 qcom-firmware && \
    dnf -y install mobility-tweaks && \
    dnf -y install iio-sensor-proxy && \
    dnf -y install phrog && \
    systemctl enable phrog.service && \
    dnf clean all && \
    bootc container lint

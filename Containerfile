FROM quay.io/fedora/fedora-bootc:rawhide

COPY etc/ /etc/
COPY usr/ /usr/

RUN dnf -y install 'dnf5-command(copr)' && \
    dnf -y copr enable gmanka/sdm845 && \
    dnf -y copr enable @mobility/common && \
    dnf -y copr enable samcday/phrog && \
    dnf -y install kernel-0:6.15.0-0.rc2.15.sdm845.fc43 kernel-modules-extra && \
    dnf -y install \
        @standard \
        @hardware-support \
        bcm283x-firmware \
        grubby \
        grub2-efi-aa64 grub2-efi-aa64-modules systemd-oomd-defaults systemd-resolved \
        fedora-release-mobility \
        glibc-langpack-en \
        btrfs-progs udisks2-btrfs \
        @core @base-graphical @phosh-desktop \
        bootmac hexagonrpc libssc pd-mapper qrtr rmtfs tqftpserv alsa-ucm-mobility-sdm845 qcom-firmware \
        mobility-tweaks \
        iio-sensor-proxy \
        phrog \
        --exclude selinux-policy-targeted,dracut-config-rescue,qemu-user-static && \
    systemctl enable phrog.service && \
    systemctl enable bootmac-bluetooth.service && \
    systemctl enable hexagonrpcd-sdsp.service && \
    systemctl enable pd-mapper.service && \
    systemctl enable rmtfs.service && \
    systemctl enable tqftpserv.service && \
    dnf clean all

COPY firmware-oneplus-sdm845/usr /usr/
COPY firmware-oneplus-sdm845/lib /usr/lib/
RUN mv /usr/lib/firmware/qcom/sdm845/oneplus6/ipa_fws.mbn{,.disabled} && \
    mv /usr/lib/firmware/postmarketos/* /usr/lib/firmware/updates && \
    rmdir /usr/lib/firmware/postmarketos

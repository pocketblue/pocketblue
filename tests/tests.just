# Local builds and tests


qemu_rootfs := "ext4"
imgtype := "qcow2"

build-qemu qemu_device="qemu" qemu_desktop="tty" output="./output/qcow2/disk.qcow2":
    #!/usr/bin/env bash
    set -euxo pipefail
    image="localhost/{{qemu_device}}-{{qemu_desktop}}:{{tag}}-build"
    just build {{base}} {{branch}} {{qemu_device}} {{qemu_desktop}} {{tag}}
    just disk $image {{imgtype}} {{qemu_rootfs}}

@qemu path="output/qcow2/disk.qcow2" memory="4096" format="qcow2":
    #!/usr/bin/env bash
    set -euxo pipefail

    test -f {{path}} || { echo "disk image not found: {{path}} \nRun 'just build-qemu' first"; exit 1; }


    QEMU=${QEMU_BIN:-$(command -v qemu-system-aarch64 || true)}
    if [ -z "$QEMU" ]; then
    echo "qemu-system-aarch64 not found in PATH" >&2
    echo "Please install 'qemu-system-aarch64' or set QEMU_BIN environment variable" >&2
    exit 1
    fi

    # common locations for AArch64 UEFI firmware (local override then distro paths)
    FW_CANDIDATES=("./tools/firmware/QEMU_EFI.fd" \
    "/usr/share/edk2/aarch64/QEMU_EFI.fd" \
    "/usr/share/AAVMF/AAVMF_CODE.fd" \
    "/usr/share/edk2-aarch64/AAVMF_CODE.fd" \
    "/usr/share/qemu-efi-aarch64/QEMU_EFI.fd" \
    "/usr/share/edk2/ovmf/OVMF_CODE.fd" \
    "/usr/share/qemu-efi-aarch64/QEMU_EFI.fd")
    # Can we glob this?
    FW=""
    for p in "${FW_CANDIDATES[@]}"; do
        if [ -f "$p" ]; then
            FW=$p
        break
    fi
    done
    if [ -z "$FW" ]; then
        echo "AArch64 UEFI firmware not found." >&2
        echo "Install your distro's 'qemu-efi-aarch64' / 'edk2-aarch64' package." >&2
        exit 1
    fi
    echo "Using firmware: $FW"

    if command -v nproc >/dev/null 2>&1; then
        SMP=$(nproc --physical 2>/dev/null || nproc)
    else
        SMP=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo 2)
    fi

    QEMU_CPU={{qemu_cpu}}
    "$QEMU" \
        -machine virt,highmem=on -cpu "$QEMU_CPU" -smp "$SMP" -m {{memory}} \
        -bios "$FW" \
        -drive if=none,file="{{path}}",id=hd0,format="{{format}}",cache=writeback \
        -device virtio-blk-device,drive=hd0 \
        -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=net0 \
        -serial mon:stdio \
        -display none


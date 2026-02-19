#!/usr/bin/env bash
set -euo pipefail

# run-qemu.sh <disk.raw> [MEMORY_MB]
# launch a `disk.raw` produced by the build pipeline
# under QEMU (aarch64/`virt` machine + UEFI).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DISK=${1:-}
MEM=${2:-4096}

if [ -z "$DISK" ] || [ ! -f "$DISK" ]; then
    echo "usage: $0 <disk.{raw,qcow2}> [memory_mb]" >&2
    exit 2
fi

# detect format by extension (qcow2/raw)
case "${DISK##*.}" in
    qcow2|QCOW2) FORMAT=qcow2 ;;
    raw|RAW) FORMAT=raw ;;
    *)
        if command -v qemu-img >/dev/null 2>&1; then
            fmt=$(qemu-img info --output=json "$DISK" 2>/dev/null | jq -r '.format' || true)
            FORMAT=${fmt:-raw}
        else
            FORMAT=raw
        fi ;;
esac

# allow a repo-local qemu binary
if [ -x "$SCRIPT_DIR/bin/qemu-system-aarch64" ]; then
    QEMU="$SCRIPT_DIR/bin/qemu-system-aarch64"
else
    QEMU=$(command -v qemu-system-aarch64 || true)
fi

if [ -z "$QEMU" ]; then
    echo "qemu-system-aarch64 not found in PATH and no local copy at $SCRIPT_DIR/bin/qemu-system-aarch64" >&2
    echo "Please install 'qemu-system-aarch64'" >&2
    exit 1
fi

# common locations for aarch64 UEFI firmware
# also check for a project-local firm (tools/firmware/QEMU_EFI.fd)
FW_CANDIDATES=("$SCRIPT_DIR/firmware/QEMU_EFI.fd" /usr/share/edk2/aarch64/QEMU_EFI.fd /usr/share/AAVMF/AAVMF_CODE.fd /usr/share/edk2-aarch64/AAVMF_CODE.fd /usr/share/qemu-efi-aarch64/QEMU_EFI.fd /usr/share/edk2/ovmf/OVMF_CODE.fd)
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

exec "$QEMU" \
    -machine virt,highmem=on -cpu cortex-a76 -smp "$SMP" -m "$MEM" \
    -bios "$FW" \
    -drive if=none,file="$DISK",id=hd0,format=${FORMAT},cache=writeback \
    -device virtio-blk-device,drive=hd0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-device,netdev=net0 \
    -serial mon:stdio -display gtk

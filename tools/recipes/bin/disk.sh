#!/usr/bin/env bash
set -euo pipefail

# Usage: disk.sh <image> [type=qcow2] [rootfs_override]
IMAGE="${1:-}"
TYPE="${2:-qcow2}"
ROOTFS_OVERRIDE="${3:-}"

if [ -z "$IMAGE" ]; then
  echo "error: image parameter required" >&2
  exit 1
fi

# fallback to repo default if override not provided
ROOTFS="${ROOTFS_OVERRIDE:-${PB_ROOTFS:-btrfs}}"
ARCH="${PB_ARCH:-arm64}"

# detect container runtime (fallback to podman/docker)
if command -v podman >/dev/null 2>&1; then
  RUNTIME=podman
elif command -v docker >/dev/null 2>&1; then
  RUNTIME=docker
else
  echo "error: need podman or docker to run this script" >&2
  exit 1
fi

echo "==> producing $TYPE disk image from $IMAGE via bootc-image-builder (rootfs: $ROOTFS)"
mkdir -p output
sudo "$RUNTIME" run \
  --rm --privileged \
  --pull=newer \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  -v "$(pwd)/bootc-image-builder.toml":/config.toml:ro \
  -v "$(pwd)/output":/output \
  --security-opt label=type:unconfined_t \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type="$TYPE" \
  --target-arch="$ARCH" \
  --rootfs="$ROOTFS" \
  "$IMAGE"

sudo chown -R "$(id -u):$(id -g)" output
echo "==> disk image ready: output/$TYPE/"

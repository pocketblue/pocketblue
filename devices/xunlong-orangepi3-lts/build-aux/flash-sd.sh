#!/usr/bin/env bash

set -euo pipefail

image="${1:-}"
device="${2:-}"

if [ -z "$image" ] || [ -z "$device" ]; then
    echo "Usage: $0 <path-to-disk.raw> <block-device>" >&2
    echo "Example: $0 images/disk.raw /dev/sdX" >&2
    exit 1
fi

dd if="$image" of="$device" bs=4M conv=fsync status=progress
sync

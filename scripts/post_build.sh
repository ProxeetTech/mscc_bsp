#!/bin/sh

DEST="$1"

PROJECT_ROOT="$(pwd)"

KERNEL_DIR=$(find "${PROJECT_ROOT}/output/build_arm64_xstax/build" -maxdepth 1 -type d -name "linux-*" | head -n 1)
if [ -z "$KERNEL_DIR" ]; then
    echo "Error: Kernel build directory starting with 'linux-' not found in ${PROJECT_ROOT}/output/build_arm64_xstax/build"
    exit 1
fi

DTBO_DIR="${KERNEL_DIR}/arch/arm64/boot/dts/microchip"

if [ ! -d "$DTBO_DIR" ]; then
    echo "Error: DTBO directory '$DTBO_DIR' does not exist."
    exit 1
fi

echo "Found kernel build directory: $KERNEL_DIR"
echo "Copying DTBO files from '$DTBO_DIR' to '$DEST'..."
mkdir -p "$DEST"
cp -v "$DTBO_DIR"/*.dtbo "$DEST/"

echo "Done."

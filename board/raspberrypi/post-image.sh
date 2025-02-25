#!/usr/bin/env bash

soc="rpi4cm"

# Remove the first argument which is the path to the +images+ output directory
shift

# The rest of the arguments comes from +BR2_ROOTFS_POST_SCRIPT_ARGS+
# Add the types to generate in +BR2_ROOTFS_POST_SCRIPT_ARGS+ separated by space

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Copy documentation"
cp -v $SCRIPT_DIR/README.adoc $BINARIES_DIR

echo "Generate itb-bare..."
$BR2_EXTERNAL_MSCC_PATH/support/scripts/imggen.rb \
    --soc $soc \
    --name fit \
    --type itb-bare \
    --kernel $BINARIES_DIR/mscc-linux-kernel.bin.gz \
    --dtb $BINARIES_DIR/bcm2711-rpi-cm4-lan966x.dtb,rpi \
    --dtb $BINARIES_DIR/bcm2711-rpi-cm4-lan969x.dtb,rpi-lan969x \
    --dtb $BINARIES_DIR/bcm2711-microchip-pcb8309.dtb,pcb8309 \
    --output $BINARIES_DIR

echo "Generate itb-rootfs..."
$BR2_EXTERNAL_MSCC_PATH/support/scripts/imggen.rb \
    --soc $soc \
    --type itb-rootfs \
    --kernel $BINARIES_DIR/mscc-linux-kernel.bin.gz \
    --dtb $BINARIES_DIR/bcm2711-rpi-cm4-lan966x.dtb,rpi \
    --dtb $BINARIES_DIR/bcm2711-rpi-cm4-lan969x.dtb,rpi-lan969x \
    --dtb $BINARIES_DIR/bcm2711-microchip-pcb8309.dtb,pcb8309 \
    --rootfs $BINARIES_DIR/rootfs.squashfs \
    --output $BINARIES_DIR

echo "Create FAT32 Image from bootfiles directory"
dd status=none if=/dev/zero of=$BINARIES_DIR/fat32.boot.img count=1 bs=256M
mkfs.fat -F32 -n "BOOT" $BINARIES_DIR/fat32.boot.img  > /dev/null
mcopy -i $BINARIES_DIR/fat32.boot.img $SCRIPT_DIR/bootfiles/* ::
mcopy -i $BINARIES_DIR/fat32.boot.img $BINARIES_DIR/u-boot.bin ::
mcopy -i $BINARIES_DIR/fat32.boot.img $BINARIES_DIR/fit.itb ::
mcopy -i $BINARIES_DIR/fat32.boot.img $BINARIES_DIR/itb-rootfs.itb ::

echo "Create EXT4 Image from target directory"
rm -rf $BINARIES_DIR/targetfs
rsync -auH --exclude=/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM $TARGET_DIR/ $BINARIES_DIR/targetfs/
mkdir -p $BINARIES_DIR/targetfs/boot
mkfs.ext4 -q -d $BINARIES_DIR/targetfs -r 1 -N 0 -m 5 -L "" -O ^64bit $BINARIES_DIR/ext4.root.img 512M > /dev/null

echo "Create Final 1GB Disk Image"
dd status=none if=/dev/zero of=$BINARIES_DIR/rpi4cm.img bs=256M count=4
parted -s $BINARIES_DIR/rpi4cm.img mktable msdos
parted -s $BINARIES_DIR/rpi4cm.img mkpart primary fat32 8192s 532479s
echo "Add FAT32 Image to Final Disk Image"
dd status=none if=$BINARIES_DIR/fat32.boot.img of=$BINARIES_DIR/rpi4cm.img seek=8192 bs=512 conv=notrunc
parted -s $BINARIES_DIR/rpi4cm.img mkpart primary ext4 532480s 100%
echo "Add EXT4 Image to Final Disk Image"
dd status=none if=$BINARIES_DIR/ext4.root.img of=$BINARIES_DIR/rpi4cm.img seek=532480 bs=512 conv=notrunc
echo "$BINARIES_DIR/rpi4cm.img created"

# The final image can be inspected with:
#   losetup -fP --show rpi4cm.img
# and then mounting the two partitions /dev/loopXp1 and /dev/loopXp2
# Finally use
#   losetup -D
# to remove the device again
# To write the file onto a device use the dd command like this:
#   sudo dd if=rpi4cm.img of=/dev/sdX bs=8M status=progress oflag=direct
#

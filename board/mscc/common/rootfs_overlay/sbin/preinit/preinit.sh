#!/bin/sh

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs -o size=512M tmpfs /tmp
chown -R root:root /var/empty
mkdir -p /tmp/update
mount /dev/mmcblk0p8 /tmp/update

exit 0

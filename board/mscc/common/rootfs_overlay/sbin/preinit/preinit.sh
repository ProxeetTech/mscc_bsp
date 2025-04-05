#!/bin/sh

CMDLINE=$(cat /proc/cmdline 2>/dev/null)

if echo "$CMDLINE" | grep -q '\brdinit\b'; then
	mount -t proc proc /proc
	mount -t sysfs sysfs /sys
	mount -t devtmpfs devtmpfs /dev
	chown -R root:root /var/empty
fi

mkdir -p /tmp/update
mount /dev/mmcblk0p8 /tmp/update

exit 0

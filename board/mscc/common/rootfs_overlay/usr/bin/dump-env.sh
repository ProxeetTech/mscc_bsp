#!/bin/sh

do_cmd()
{
    echo "===================================="
    echo $1
    echo "===================================="
    sh -c "$2"
    echo
}

do_file()
{
    if [ -r $2 ]
    then
	do_cmd "$1" "cat $2"
    else
	do_cmd "$1" "echo *No file*: $2"
    fi
}

do_uboot_vers()
{
    do_cmd "U-Boot version" "strings $1 | grep 'U-Boot 20'"
}

do_uboot()
{
    [ -f /proc/mtd ] || return
    if grep mtd0 /proc/mtd | grep -q "UBoot"
    then
	do_uboot_vers /dev/mtd0
    else
    if grep mtd1 /proc/mtd | grep -q "UBoot"
	then
	    do_uboot_vers /dev/mtd1
	else
	    do_cmd "U-Boot version" "U-Boot not found"
	fi
    fi
}

do_cmd "System version" "uname -a"
do_cmd "System status" "top -b -n 1"
do_file "Storage partitions" "/proc/mtd"
do_cmd "Storage capacity" "df -h"
do_file "Interrupt status" "/proc/interrupts"
do_file "FDMA status" "/proc/vc3fdma"
do_uboot
do_cmd "Kernel log" "dmesg"

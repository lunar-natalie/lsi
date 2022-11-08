#!/bin/sh
#
# qemu.sh
#
# Runs an LSI disk image in QEMU.
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

. ./.local.sh
. ./util.sh

QEMU="qemu-system-$TARGET_MACH"
QEMU_BASE_OPTIONS="-cdrom $DISK_IMAGE"

if ! is_set QEMU_USE_GDB
then
    "$QEMU" $QEMU_BASE_OPTIONS
else
    GDB_SOCKET=.gdb.socket
    GDB_SOCKET_ID=gdb0

    "$QEMU" $QEMU_BASE_OPTIONS \
-chardev socket,path=$GDB_SOCKET,server=on,wait=off,id=$GDB_SOCKET_ID \
-gdb chardev:$GDB_SOCKET_ID \
-S &

    while [ ! -e "$GDB_SOCKET" ]
    do
        sleep 1
    done

    gdb \
-ex "file '$SYSROOT/boot/lsimage'" \
-ex "target remote $GDB_SOCKET"

    wait
fi

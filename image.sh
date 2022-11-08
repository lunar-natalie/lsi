#!/bin/sh
#
# image.sh
#
# Creates a bootable system disk image.
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

. ./.local.sh

grub-mkrescue -o "$DISK_IMAGE" "$SYSROOT" image

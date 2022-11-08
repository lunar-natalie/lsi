#
# build.mk
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

kernel_CFLAGS = -ffreestanding -Wall -Wextra
kernel_CPPFLAGS = -D__is_kernel
kernel_LDFLAGS = -nostdlib

kernel_SOURCES = \
main.c \
tty.c

kernel_LIBNAMES = k

kernel_BIN = lsimage

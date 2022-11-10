#
# build.mk
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

kernel_i386_CFLAGS =
kernel_i386_CPPFLAGS =
kernel_i386_LDFLAGS =

kernel_i386_OBJECTS = \
boot.o

kernel_i386_boot_CFLAGS = -O0 -fomit-frame-pointer

kernel_i386_LINKERSCRIPT = linker.ld

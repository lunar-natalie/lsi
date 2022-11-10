#
# build.mk
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

lib_CFLAGS = -ffreestanding -Wall -Wextra
lib_CPPFLAGS = -D__is_libk
lib_ARFLAGS = -rcs

lib_OBJECTS = \
string.o

lib_ARCHIVE = libk.a

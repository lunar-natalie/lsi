#
# Makefile
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

include .local.mk
ARCHDIR = arch/$(ARCH)
BOOTDIR = $(SYSROOT)/boot
INCDIR = $(SYSROOT)/include
CFLAGS += -Iinclude -I$(ARCHDIR)/include
LDFLAGS += -L.

include lib/build.mk
lib_OBJECTS := $(lib_OBJECTS:%=lib/%)

lib_CFLAGS := $(CPPFLAGS) $(lib_CPPFLAGS) $(CFLAGS) $(lib_CFLAGS)

DEPENDENCIES += $(lib_OBJECTS:%.o=%.d)

include kernel/build.mk
include $(ARCHDIR)/kernel/build.mk
kernel_OBJECTS := $(kernel_OBJECTS:%=kernel/%)
kernel_ARCH_OBJECTS = $(kernel_$(ARCH)_OBJECTS:%=$(ARCHDIR)/kernel/%)
kernel_ALL_OBJECTS = $(kernel_OBJECTS) $(kernel_ARCH_OBJECTS)

kernel_ARCHIVES = $(kernel_LIBS:%=lib%.a)
kernel_LINKERSCRIPT = $(ARCHDIR)/kernel/$(kernel_$(ARCH)_LINKERSCRIPT)
kernel_OUT = $(SYSROOT)/boot/$(kernel_BIN)

kernel_CFLAGS := $(CFLAGS) $(kernel_CFLAGS) $(kernel_$(ARCH)_CFLAGS) \
		$(CPPFLAGS) $(kernel_CPPFLAGS) $(kernel_$(ARCH)_CPPFLAGS)

kernel_AUX_LDFLAGS = -T$(kernel_LINKERSCRIPT) $(kernel_LIBS:%=-l%)
kernel_LDFLAGS := $(LDFLAGS) $(kernel_LDFLAGS) $(kernel_AUX_LDFLAGS) \
		$(kernel_$(ARCH)_LDFLAGS)

DEPENDENCIES += $(kernel_ALL_OBJECTS:%.o=%.d)

.PHONY: all clean mrproper $(BOOTDIR) $(INCDIR)
ifndef VERBOSE
.SILENT:
endif

all: $(kernel_OUT) $(INCDIR)

$(BOOTDIR):
	mkdir -p $@

$(INCDIR):
	mkdir -p $@
	cp -R include/* $(ARCHDIR)/include/* $@

$(kernel_OUT): $(kernel_ALL_OBJECTS) $(kernel_ARCHIVES) $(BOOTDIR)
	@echo ' LD' $@
	$(LD) $(kernel_LDFLAGS) $(kernel_ALL_OBJECTS) -o $@

$(lib_ARCHIVE): $(lib_OBJECTS)
	@echo ' AR' $@
	$(AR) $(lib_ARFLAGS) $@ $^

$(kernel_ALL_OBJECTS): MODULE = kernel

$(lib_OBJECTS): MODULE = lib

.c.o:
	@echo ' CC' $@
	$(CC) $($(MODULE)_CFLAGS) \
		$($(patsubst $(ARCHDIR)/$(MODULE)/%,$(MODULE)_$(ARCH)_CFLAGS,$(@D))) \
		$($(subst /,_,$(patsubst \
			$(ARCHDIR)/$(MODULE)/%,$(MODULE)_$(ARCH)/%_CFLAGS,$(@D)))) \
		-c $< -o $@

clean:
	rm -f $(kernel_ALL_OBJECTS) $(lib_OBJECTS)

mrproper: clean
	rm -f $(kernel_OUT) $(lib_ARCHIVE) $(DEPENDENCIES)

-include $(DEPENDENCIES)

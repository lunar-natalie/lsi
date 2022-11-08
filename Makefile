#
# Makefile
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

# Global macros

include .local.mk

ARCHDIR = arch/$(TARGET_ARCH)

CFLAGS += -MMD
CPPFLAGS += -Iinclude -I$(ARCHDIR)/include
LDFLAGS += -L.

# Libary macros

include lib/build.mk
lib_GLOBAL_SOURCES = $(lib_SOURCES:%=lib/%)
lib_OBJECTS = $(lib_GLOBAL_SOURCES:%=%.o)
DEPENDENCIES += $(lib_GLOBAL_SOURCES:%=%.d)

lib_GLOBAL_CFLAGS = $(CPPFLAGS) $(lib_CPPFLAGS) $(CFLAGS) $(lib_CFLAGS)

# Kernel macros

include kernel/build.mk
include $(ARCHDIR)/kernel/build.mk
kernel_GLOBAL_SOURCES = $(kernel_SOURCES:%=kernel/%) \
$(kernel_$(TARGET_ARCH)_SOURCES:%=$(ARCHDIR)/kernel/%)

kernel_OBJECTS = $(kernel_GLOBAL_SOURCES:%=%.o)
DEPENDENCIES += $(kernel_GLOBAL_SOURCES:%=%.d)
kernel_OUT = $(SYSROOT)/boot/$(kernel_BIN)

kernel_LIBS = $(kernel_LIBNAMES:%=lib%.a)
kernel_LINKERSCRIPT = $(ARCHDIR)/kernel/$(kernel_$(TARGET_ARCH)_LINKERSCRIPT)
kernel_AUX_LDFLAGS = -T$(kernel_LINKERSCRIPT) $(kernel_LIBNAMES:%=-l%)

kernel_GLOBAL_CFLAGS = $(CPPFLAGS) $(kernel_CPPFLAGS) \
$(kernel_$(ARCH)_CPPFLAGS) $(CFLAGS) $(kernel_CFLAGS) \
$(kernel_$(TARGET_ARCH)_CFLAGS)
kernel_GLOBAL_LDFLAGS = $(LDFLAGS) $(kernel_LDFLAGS) $(kernel_AUX_LDFLAGS) \
$(kernel_$(TARGET_ARCH)_LDFLAGS)

# Targets

.PHONY: all clean mrproper $(SYSROOT)

all: $(SYSROOT) $(kernel_OUT)

$(SYSROOT):
	mkdir -p $(SYSROOT)/{boot,include}
	cp -R include/* $(ARCHDIR)/include/* $(SYSROOT)/include

$(kernel_OUT): $(kernel_OBJECTS) $(kernel_LIBS)
	$(LD) $(kernel_GLOBAL_LDFLAGS) $(kernel_OBJECTS) -o $@

$(lib_LIB): $(lib_OBJECTS)
	$(AR) $(lib_ARFLAGS) $@ $^

kernel/%.c.o:
	$(CC) $(kernel_GLOBAL_CFLAGS) $(kernel_$*_CFLAGS) kernel/$*.c -c -o $@

$(ARCHDIR)/kernel/%.c.o:
	$(CC) $(kernel_GLOBAL_CFLAGS) $(kernel_$(TARGET_ARCH)_$*_CFLAGS) $(@D)/$*.c -c -o $@

lib/%.c.o:
	$(CC) $(lib_GLOBAL_CFLAGS) $(lib_$*_CFLAGS) $(@D)/$*.c -c -o $@

clean:
	rm $(kernel_OBJECTS) $(lib_OBJECTS)

mrproper: clean
	rm $(kernel_OUT) $(lib_LIB) $(DEPENDENCIES)

-include $(DEPENDENCIES)

#
# Makefile
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

include .local.mk
ARCHDIR = arch/$(ARCH)
CPPFLAGS += -Iinclude -I$(ARCHDIR)/include
LDFLAGS += -L.

include lib/build.mk
lib_GLOBAL_OBJECTS = $(lib_OBJECTS:%=lib/%)
lib_ALL_CFLAGS = $(CPPFLAGS) $(lib_CPPFLAGS) $(CFLAGS) $(lib_CFLAGS)
DEPENDENCIES += $(lib_GLOBAL_OBJECTS:%.o=%.d)

include kernel/build.mk
include $(ARCHDIR)/kernel/build.mk
kernel_GLOBAL_OBJECTS = $(kernel_OBJECTS:%=kernel/%)
kernel_ARCH_OBJECTS = $(kernel_$(ARCH)_OBJECTS:%=$(ARCHDIR)/kernel/%)
kernel_ARCHIVES = $(kernel_LIBS:%=lib%.a)
kernel_LINKERSCRIPT = $(ARCHDIR)/kernel/$(kernel_$(ARCH)_LINKERSCRIPT)
kernel_OUT = $(SYSROOT)/boot/$(kernel_BIN)

kernel_ALL_CFLAGS = $(CFLAGS) $(kernel_CFLAGS) $(kernel_$(ARCH)_CFLAGS) \
$(CPPFLAGS) $(kernel_CPPFLAGS) $(kernel_$(ARCH)_CPPFLAGS)

kernel_AUX_LDFLAGS = -T$(kernel_LINKERSCRIPT) $(kernel_LIBS:%=-l%)
kernel_ALL_LDFLAGS = $(LDFLAGS) $(kernel_LDFLAGS) $(kernel_AUX_LDFLAGS) \
$(kernel_$(ARCH)_LDFLAGS)

DEPENDENCIES += $(kernel_GLOBAL_OBJECTS:%.o=%.d) $(kernel_ARCH_OBJECTS:%.o=%.d)

.PHONY: $(SYSROOT) all clean mrproper

all: $(SYSROOT) $(kernel_OUT)

$(SYSROOT):
	mkdir -p $(SYSROOT)/{boot,include}
	cp -R include/* $(ARCHDIR)/include/* $(SYSROOT)/include

$(kernel_OUT): $(kernel_GLOBAL_OBJECTS) $(kernel_ARCH_OBJECTS) \
$(kernel_ARCHIVES)
	@echo ' LD' $@
	@$(LD) $(kernel_ALL_LDFLAGS) $(kernel_GLOBAL_OBJECTS) $(kernel_ARCH_OBJECTS) -o $@

$(lib_ARCHIVE): $(lib_GLOBAL_OBJECTS)
	@echo ' AR' $@
	@$(AR) $(lib_ARFLAGS) $@ $^

.c.o:
	@echo ' CC' $@
	@$(CC) $($(@D:$(ARCHDIR)/%=%)_ALL_CFLAGS) $($(@D:$(ARCHDIR)/%=%_$(ARCH))_$(*F)_CFLAGS) -c $< -o $@

clean:
	rm -f $(kernel_GLOBAL_OBJECTS) $(kernel_ARCH_OBJECTS) $(lib_GLOBAL_OBJECTS)

mrproper: clean
	rm -f $(kernel_OUT) $(lib_ARCHIVE) $(DEPENDENCIES)

-include $(DEPENDENCIES)

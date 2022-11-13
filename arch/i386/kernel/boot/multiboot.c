/*
 * multiboot.c
 *
 * Mutliboot data for kernel bootstrap.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#include <boot/multiboot2.h>

#include <stdint.h>

extern void _start(void);

#define __multiboot__ __attribute__((section(".multiboot")))
#define __tag__ __attribute__((aligned(8)))

#define MULTIBOOT_HEADER_LENGTH                                                \
    (2 * sizeof(multiboot_uint32_t)) / sizeof(multiboot_uint16_t)

struct multiboot_header header __multiboot__ = {
    MULTIBOOT2_HEADER_MAGIC,     // Magic
    MULTIBOOT_ARCHITECTURE_I386, // Architecture
    MULTIBOOT_HEADER_LENGTH,     // Length of above fields in 16-bit words
    -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386
      + MULTIBOOT_HEADER_LENGTH) // Checksum
};

struct multiboot_header_tag_entry_address tag_entry __multiboot__ __tag__ = {
    MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS,                // Type
    0,                                                 // Flags
    sizeof(struct multiboot_header_tag_entry_address), // Size
    (multiboot_uint32_t) _start                        // Entry address
};

struct multiboot_header_tag tag_end __multiboot__ __tag__ = {
    MULTIBOOT_HEADER_TAG_END, // Type
    0,                        // Flags
    8                         // Size (magic)
};

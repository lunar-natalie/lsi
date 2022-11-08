/*
 * boot.c
 *
 * Kernel bootstrap code.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#include <boot/multiboot2.h>

#include <stdbool.h>
#include <stdint.h>

// 16KiB, 16-bit aligned stack space.
uint32_t stack[0x4000] __attribute__((section(".bss"), aligned(2)));

extern void kmain(void);

// Kernel entry stub.
void __attribute__((section(".bootstrap"), noreturn)) _start(void)
{
    // Set stack pointer to top of stack.
    __asm__("movl %0, %%esp" : : "r"(stack + sizeof(stack)));

    // Enter kernel.
    kmain();

    // In the event of a fatal exception causing kmain() to return, disable
    // maskable interrupts, halt execution and loop if an NMI is encountered.
    __asm__("cli");
    while (true) {
        __asm__("hlt");
    }
}

// Multiboot header.

#define MULTIBOOT_HEADER_LENGTH                                                \
    (2 * sizeof(multiboot_uint32_t)) / sizeof(multiboot_uint16_t)

struct multiboot_header kernel_multiboot_header
    __attribute__((section(".multiboot"))) = {
        MULTIBOOT2_HEADER_MAGIC,     // Magic
        MULTIBOOT_ARCHITECTURE_I386, // Architecture
        MULTIBOOT_HEADER_LENGTH,     // Length of above fields in 16-bit words
        -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386
          + MULTIBOOT_HEADER_LENGTH) // Checksum
};

#define __multiboot_tag__ __attribute__((section(".multiboot"), aligned(8)))

struct multiboot_header_tag_entry_address
    kernel_multiboot_entry_address_tag __multiboot_tag__ = {
        MULTIBOOT_HEADER_TAG_ENTRY_ADDRESS,                // Type
        0,                                                 // Flags
        sizeof(struct multiboot_header_tag_entry_address), // Size
        (multiboot_uint32_t) _start                        // Entry address
};

struct multiboot_header_tag kernel_multiboot_end_tag
    __multiboot_tag__ = {
        MULTIBOOT_HEADER_TAG_END, // Type
        0,                        // Flags
        8                         // Size (magic)
};

/*
 * start.c
 *
 * Kernel bootstrap entrypoint.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#include <lsi/attributes.h>

#include <stdbool.h>
#include <stdint.h>

// 16KiB, 16-bit aligned stack space for the initial thread.
uint32_t stack[0x4000] __section__(".bss", "aw", "@nobits")
    __attribute__((aligned(2)));

extern void kmain(void);

// Kernel entry stub.
void __attribute__((section(".bootstrap"), noreturn)) _start(void)
{
    __asm__ ("movl %0, %%esp" : : "r"(stack + sizeof(stack)));

    // Enter kernel.
    kmain();

    // In the event of a fatal exception causing kmain() to return, disable
    // maskable interrupts, halt execution and loop if an NMI is encountered.
    __asm__("cli");
    while (true) {
        __asm__("hlt");
    }
}

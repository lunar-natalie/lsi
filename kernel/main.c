/*
 * main.c
 *
 * Kernel entry point loaded by the bootstrap code.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#include <lsi/tty.h>

#include <stdbool.h>

// Kernel entry point.
void __attribute__((noreturn)) kmain(void)
{
    terminal_init();
    terminal_clear();
    terminal_write("LSI Kernel 0.1");
    while (true) {
        continue;
    }
}

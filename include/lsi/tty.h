/*
 * tty.h
 *
 * Terminal functions.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#ifndef _LSI_TTY_H
#define _LSI_TTY_H

#include <stddef.h>

// Initializes the terminal's VGA output attributes, including buffer location,
// size, position and color.
void terminal_init(void);

// Clears the terminal contents.
void terminal_clear(void);

// Sets the current position in the terminal to the specified column and row.
void terminal_setpos(size_t col, size_t row);

/// Writes a chracter to the terminal and updates the terminal position.
void terminal_putchar(unsigned char c);

// Writes a string to the terminal and updates the terminal position.
void terminal_write(const char *s);

#endif // _LSI_TTY_H

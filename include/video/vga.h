/*
 * vga.h
 *
 * VGA graphics interface.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#ifndef _VIDEO_VGA_H_
#define _VIDEO_VGA_H_

#include <stddef.h>
#include <stdint.h>

#define VGA_TEXT_BUFFER 0xb8000

// Represents the data or index of a text entry in video memory.
typedef uint16_t vga_entry;

// Foreground and background color data for VGA text entries.
typedef uint8_t vga_color;

// Foreground/background colors.
enum VGA_COLOR {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GRAY = 7,
    VGA_COLOR_DARK_GRAY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15
};

// Creates a VRAM-writable VGA text entry with character and color data.
static inline vga_entry create_vga_entry(unsigned char c, vga_color color)
{
    return (vga_entry) c | ((vga_entry) color << 8);
}

// Creates color data for a VGA entry from a specified foreground and background
// color.
static inline vga_color create_vga_color(enum VGA_COLOR fg, enum VGA_COLOR bg)
{
    return fg | (bg << 4);
}

// Gets the index of a VGA text entry into the VRAM buffer from the row and
// column position of the entry, and the buffer's width in columns.
static inline vga_entry get_vga_index(size_t row, size_t col, size_t width)
{
    return (row * width) + col;
}

#endif // _VIDEO_VGA_H_

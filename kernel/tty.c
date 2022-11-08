/*
 * tty.c
 *
 * Terminal handler.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#include <lsi/tty.h>
#include <video/vga.h>

#include <stdbool.h>
#include <string.h>

// Attributes for displaying VGA text.
static struct vga_text_attributes {
    // Text mode video memory buffer.
    volatile vga_entry *buffer;

    // Buffer width in columns.
    size_t width;

    // Buffer height in rows.
    size_t height;

    // Current column in buffer.
    size_t col;

    // Current row in buffer.
    size_t row;

    // Final column in buffer.
    size_t max_col;

    // Final row in buffer.
    size_t max_row;

    // Current entry color.
    vga_color color;
} vga;

// Flags for handling the terminal between operations.
static struct terminal_flags {
    // Scroll display by one row when printing the next character.
    bool scroll_next;
} flags;

// Scrolls the terminal buffer by one row.
void terminal_scroll(void)
{
    // Swap each row with the next, moving each row up by one.
    for (size_t row = 0; row < vga.max_row; ++row) {
        for (size_t col = 0; col < vga.max_col; ++col) {
            vga_entry current_index = get_vga_index(row, col, vga.width);
            vga_entry next_index = get_vga_index(row + 1, col, vga.width);
            vga.buffer[current_index] = vga.buffer[next_index];
        }
    }

    const vga_entry null_entry = create_vga_entry(0, vga.color);
    const vga_entry max_index =
        get_vga_index(vga.max_row, vga.width, vga.width);
    // Clear the last row.
    for (size_t i = vga.max_row * vga.width; i < max_index; ++i) {
        vga.buffer[i] = null_entry;
    }
}

// Called when the end of the current line is reached to update VGA attributes
// and flags.
inline void terminal_eol()
{
    vga.col = 0;
    // If on the last row, scroll on the next print, otherwise move to the
    // next row.
    if (vga.row == vga.max_row) {
        flags.scroll_next = true;
    } else {
        ++vga.row;
    }
}

void terminal_init(void)
{
    vga.buffer = (volatile vga_entry *) VGA_TEXT_BUFFER;
    vga.width = 80;
    vga.height = 25;
    vga.col = 0;
    vga.row = 0;
    vga.max_col = vga.width - 1;
    vga.max_row = vga.height - 1;
    vga.color = create_vga_color(VGA_COLOR_LIGHT_GRAY, VGA_COLOR_BLACK);
    flags.scroll_next = false;
}

void terminal_clear(void)
{
    const vga_entry null_entry = create_vga_entry(0, vga.color);
    // Clear character data and set color data for each entry in the buffer.
    for (size_t current_index, row = 0; row < vga.height; ++row) {
        for (size_t col = 0; col < vga.width; ++col) {
            current_index = get_vga_index(row, col, vga.width);
            vga.buffer[current_index] = null_entry;
        }
    }
}

void terminal_setpos(size_t col, size_t row)
{
    vga.col = col;
    vga.row = row;
}

void terminal_putchar(unsigned char c)
{
    if (c == '\n') {
        terminal_eol();
    } else {
        // If the scroll flag was set by the last operation, scroll to the next
        // line and clear the flag.
        if (flags.scroll_next) {
            terminal_scroll();
            flags.scroll_next = false;
        }

        // Set buffer entry using the specified character and current terminal
        // attributes.
        vga_entry current_index = get_vga_index(vga.row, vga.col, vga.width);
        vga.buffer[current_index] = create_vga_entry(c, vga.color);
        ++vga.col;

        if (vga.col == vga.max_col) {
            terminal_eol();
        }
    }
}

void terminal_write(const char *s)
{
    for (size_t i = 0; i < strlen(s); ++i) {
        terminal_putchar(s[i]);
    }
}

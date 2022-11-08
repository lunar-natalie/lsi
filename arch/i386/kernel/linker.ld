/*
 * linker.ld
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

ENTRY(_start)
SECTIONS
{
	. = 1M;

	/* Multiboot 2 header and kernel code. */
	.text : ALIGN(8K)
	{
		KEEP(*(.multiboot))
        KEEP(*(.bootstrap))
		*(.text)
	}

	/* Read-only data. */
	.rodata : ALIGN(4K)
	{
		*(.rodata)
	}

	/* Initialized read-write data. */
	.data : ALIGN(4K)
	{
		*(.data)
	}

	/*
	 * Block starting symbol (uninitialized read-write data, including the
	 * stack).
	 */
	.bss : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}
}

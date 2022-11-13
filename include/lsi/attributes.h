/*
 * attributes.h
 *
 * Pre-processed compilation and linkage attributes.
 *
 * Copyright (c) 2022 The LSI Authors.
 *
 * SPDX-License-Identifier: GPL-3.0
 */

#ifndef _LSI_ATTRIBUTES_H_
#define _LSI_ATTRIBUTES_H_

// Links symbol to section 'name'. 'flags' may be empty to use the toolchain's
// default, or any combination of "a" (allocatable), "w" (writable), or "x"
// (executable). 'type' may be empty to use the toolchain's default, or either
// "@progbits" (section contains data) or "@nobits" (section does not contain
// data at compile-time and only occupies space).
#define __section__(name, flags, type)                                         \
    __attribute__((section(name ",\"" flags ",\"" type "#")))

#endif // _LSI_ATTRIBUTES_H_

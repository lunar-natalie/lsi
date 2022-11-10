# Lunar System Interface kernel
The Lunar System Interface (LSI) kernel aims to be a monolithic, modular,
UNIX-like kernel.

## Table of contents
* [Lunar System Interface kernel](#lunar-system-interface-kernel)
  * [Table of contents](#table-of-contents)
  * [Documentation](#documentation)
  * [Build environment](#build-environment)
    * [Requirements](#requirements)
    * [Configuration](#configuration)
    * [Command line](#command-line)
  * [Creating a bootable disk image](#creating-a-bootable-disk-image)
    * [Requirements](#requirements-1)
    * [Command line](#command-line-1)
  * [Emulation and debugging](#emulation-and-debugging)
    * [Requirements](#requirements-2)
    * [Command line](#command-line-2)
  * [Structure](#structure)
  * [Coding style](#coding-style)
  * [Roadmap](#roadmap)
  * [License](#license)

## Documentation
* Documentation and code is written in United States English for integration
  with other programs.
* Shell commands to be run as user are denoted by shell code blocks.

## Build environment
### Requirements
* `make` ([Public domain POSIX make][www-pdpmake] (pdpmake), GNU make, or other
  POSIX-compliant make supporting the pdpmake extensions)
* `clang` (version 6 or later)
* `cut`
* `llvm`
* `sh` (POSIX-compliant)

Additional:
* `uname` if target is not specified

### Configuration
The environment first be configured with `configure.sh` before building or
testing from the build environment. See output of `./configure.sh --help` for
all available options.

Configurations:
* Testing:
  * Host: Arch Linux

    Target: PC with i386 architecture

    System root: `./sysroot`

    [Debugging from emulation script](#emulation-and-debugging) enabled.

    Command line:
    ```shell
    ./configure.sh --target=i386-pc-none-elf --sysroot=sysroot --qemu-gdb
    ```

### Command line
```shell
make
```
Builds the kernel image and installs all system files to the configured system
root.

## Creating a bootable disk image
### Requirements
* `grub-mkrescue`
* `xorriso`

### Command line
```shell
./image.sh
```
Outputs a bootable disk image to the configured disk image path (`lsi.iso` by
default).

## Emulation and debugging
### Requirements
* `qemu-system-<mach>` (using configured machine name `<mach>`)

Debugging:
* `gdb`

### Command line
```shell
./qemu.sh
```
Emulates the created disk image in [QEMU][www-qemu]; starts [GDB][www-gdb] and
connects the process to QEMU if debugging support is enabled.

## Structure
* Each module is built by the root `Makefile` and contains a `build.mk` included
  by the root Makefile with a build configuration relative to the directory of
  the module.
* The `kernel` module consists of all code internal to the kernel iteself.
* The `lib` module consists of code for `libk` - the library containing
  freestanding code used by kernel components.
* Architecture-specific code is placed in `arch/<arch>/<module>`, where `<arch>`
  is the target architecture and `<module>` is the module to which code and
  configuration will be added. Modules are configured to use
  architecture-specific objects with `arch/<arch>/<module>/build.mk`.
* Headers accessible by all modules are located in `include` and will be copied
  to the system root in the build process.
    * Architecture-specific headers are located in `arch/<arch>/include`; only
      headers specific to the configured target architecture will be accessible
      from modules and copied to the system root.
* `image` contains files for the creation of the bootable disk image.

## Coding style
* Lines should be no longer than 80 characters, unless readability or
  functionality is significantly affected.
* Each source file should begin with a comment formatted as follows:

  ```
  <filename>

  <description>

  Copyright (c) <year> <authors>.

  SPDX-License-Identifier: <identifier>
  ```
* Code should fit the conditions specified in `.editorconfig` and
  `.clang-format` (see the [ClangFormat documentation][www-clang-format] for
  more information).

## Roadmap
The long term goal of the LSI kernel is to provide the most common UNIX-like
interfaces and syscalls to support an external libc. In the short term, the
focus of the kernel is to implement only the fundamental features to work
towards a funtional userspace with I/O on x86.

Feature checklist for current stage:
* [x] [Multiboot2][www-multiboot2]
  compliant, bootable from GRUB
* [x] Basic VGA text mode console handler
* [ ] Higher half mapping
* [ ] Keyboard handler
  * [ ] IRQ interface

## License
Copyright (c) 2022 The LSI Authors.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

Written by Natalie Wiggins.

See `LICENSE` and `AUTHORS` for more information.


[www-pdpmake]: https://frippery.org/make
[www-qemu]: https://www.qemu.org/
[www-gdb]: https://sourceware.org/gdb/
[www-clang-format]: https://clang.llvm.org/docs/ClangFormat.html
[www-multiboot2]: https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html

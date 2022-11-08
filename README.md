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
    * [Roadmap](#roadmap)
    * [License](#license)

## Documentation
TODO

## Build environment
### Requirements
* `make` ([Public domain POSIX make](https://frippery.org/make) (pdpmake),
  GNU make, or other POSIX-compliant make supporting the pdpmake extensions)
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
* Testing
  * Host: Arch Linux

    Target: PC with i386 architecture

    Sysroot: `./sysroot`

    [Debugging from emulation script](#emulation-and-debugging) enabled

    Command line:
    ```shell
    ./configure.sh --target=i386-pc-none-elf --sysroot=sysroot --qemu-gdb
    ```

### Command line
```shell
make
```
Builds the kernel image and installs all system files to the configured sysroot.

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

## Structure
TODO

## Roadmap
TODO

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

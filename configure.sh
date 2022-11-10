#!/bin/sh
#
# configure.sh
#
# Configures the build environment.
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

. ./util.sh

SCRIPT_BASENAME=$(basename "$0")

unset CPPFLAGS
unset LDFLAGS
unset QEMU_USE_GDB
unset TARGET
unset ARCH
unset MACH
AR="llvm-ar"
CC="clang"
CFLAGS="-O2 -MMD -g -std=c17"
CONFIG_MK=".local.mk"
CONFIG_SH=".local.sh"
DISK_IMAGE="lsi.iso"
LD="ld.lld"
SYSROOT=

MK_ENVNAMES="\
AR
ARCH
CC
CFLAGS
CPPFLAGS
LD
LDFLAGS
MACH
SYSROOT
TARGET"

SH_ENVNAMES="\
DISK_IMAGE
MACH
QEMU_USE_GDB
SYSROOT"

HELP="Configuration utility for the LSI build system.

Usage: $SCRIPT_BASENAME [options]

Mandatory arguments to long options are mandatory for short options too. Long
options with mandatory arguments may be specified as either '--<name>=<value>'
or '--<name> <value>'.

Options:
      --ar=<value>          Specify archiver executable
                              Default: $AR
      --cc=<value>          Specify C compiler executable
                              Default: $CC
      --cflags=<string>     Specify global C compiler flags. The '-target' flag
                            is automatically appended to these flags with its
                            corresponding value
                              Default: $CFLAGS
      --config-mk=<file>    Specify the output file for make(1) configuration
                              Default: $CONFIG_MK
      --config-sh=<file>    Specify the output file for sh(1p) configuration
                              Default: $CONFIG_SH
      --cppflags=<string>   Specify global C pre-processor flags
      --disk-image=<file>   Specify disk image path for disk image creation and
                            system emulation scripts
                              Default: $DISK_IMAGE
      --dry-run             Do not write configuration to output files
      --ld=<value>          Specify linker executable
                              Default: $LD
      --ldflags=<string>    Specify global linker flags
      --qemu-gdb            Use the GNU debugger in the emulation script
      --sysroot=<directory> Specify the target system root
                              Default: $SYSROOT/
      --target=<triple>     Specify the target architecture. The triple has the
                            general format '<mach><sub>-<vendor>-<sys>-<abi>'.
                            If the target is not specified, the host
                            architecture is used as the target and uname(1) is
                            used to get the machine type
  -v, --verbose             Show configuration and use verbose output
  -h, --help                Display this help and exit"

# Echoes $1 to standard error and exits with code $2.
fatal() {
    echo "$1" >&2
    exit $2
}

# Handles invalid invocation of the script, using $1 as the base error message.
err_invoc() {
    fatal "$SCRIPT_BASENAME: $1
Try '$SCRIPT_BASENAME --help' for more information." 1
}

# Sets the parameter with name $1 to the argument of the current long
# ('--'-prefixed) option parsed by getopts. Command line arguments must be
# passed from $2 onwards. OPT must be set to the current option name without
# its '--' prefix, and without its value including '=' delimiter if applicable.
# OPTSTR must be set to the entire option until the first whitespace.
get_long_optarg() {
    if [ "$OPT" = "$OPTSTR" ]
    then
        OPTIND=$(($OPTIND+1))
        VALUE=$(eval echo "\$$OPTIND")
    else
        VALUE=$(echo "$OPTSTR" | cut -d'=' -f2-)
    fi

    if [ -z "$VALUE" ]
    then
        err_invoc "option '--$OPT' requires an argument"
    fi

    eval $1="$VALUE"
}

# Echoes $1 to standard error if VERBOSE is set.
log_verbose() {
    if is_set VERBOSE
    then
        echo "$1" >&2
    fi
}

help_function() {
    echo "$HELP"
    exit
}

while getopts ":hv-:" OPT
do
    case "$OPT" in
        "-")
            OPT=$(echo "$OPTARG" | cut -d'=' -f1)
            OPTSTR="$OPTARG"
            case "$OPT" in
                "ar")
                    get_long_optarg AR $@
                    ;;
                "cc")
                    get_long_optarg CC $@
                    ;;
                "cflags")
                    get_long_optarg CFLAGS $@
                    ;;
                "config-mk")
                    get_long_optarg CONFIG_MK $@
                    ;;
                "config-sh")
                    get_long_optarg CONFIG_SH $@
                    ;;
                "cppflags")
                    get_long_optarg CPPFLAGS $@
                    ;;
                "disk-image")
                    get_long_optarg DISK_IMAGE $@
                    ;;
                "dry-run")
                    DRY_RUN=
                    ;;
                "ld")
                    get_long_optarg LD $@
                    ;;
                "ldflags")
                    get_long_optarg LDFLAGS $@
                    ;;
                "qemu-gdb")
                    QEMU_USE_GDB=
                    ;;
                "sysroot")
                    get_long_optarg SYSROOT $@
                    ;;
                "target")
                    get_long_optarg TARGET $@
                    ;;
                "help")
                    help_function
                    ;;
                "verbose")
                    VERBOSE=
                    ;;
                ?)
                    err_invoc "unrecognized option '--$OPT'"
                    ;;
            esac
            ;;
        "h")
            help_function
            ;;
        "v")
            VERBOSE=
            ;;
        ?)
            CMDLINE_OPT=$(eval echo "\$$((OPTIND-1))")
            err_invoc "unrecognized option '$CMDLINE_OPT'"
            ;;
    esac
done

if [ -n "$TARGET" ]
then
    CFLAGS="$CFLAGS -target $TARGET"
    MACH=$(echo "$TARGET" | cut -d'-' -f1)
else
    MACH=$(uname -m)
fi

case "$MACH" in
    "x86"*)
        ARCH="i386"
        ;;
    *)
        ARCH="$MACH"
        ;;
esac

MK_ENV=$(echo "$MK_ENVNAMES" | while read NAME
do
    if is_set "$NAME"
    then
        echo "$NAME = $(eval echo \$$NAME)"
    fi
done;)

SH_ENV="$(echo "$SH_ENVNAMES" | while read NAME
do
    if is_set "$NAME"
    then
        VALUE=$(eval echo \$$NAME)
        if [ -z "$VALUE" ]
        then
            echo "$NAME="
        else
            echo "$NAME=\"$VALUE\""
        fi
    fi
done;)"

log_verbose "\
make(1) configuration file: $CONFIG_MK
sh(1p) configuration file: $CONFIG_SH

make(1) configuration:
$MK_ENV

sh(1p) configuration:
$SH_ENV
"

if ! is_set DRY_RUN
then
    log_verbose "Writing $CONFIG_MK"
    echo "$MK_ENV" >"$CONFIG_MK"
    log_verbose "Writing $CONFIG_SH"
    echo "$SH_ENV" >"$CONFIG_SH"
else
    log_verbose "No files changed."
fi

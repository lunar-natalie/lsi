#
# util.sh
#
# Utilities for shell scripts.
#
# Copyright (c) 2022 The LSI Authors.
#
# SPDX-License-Identifier: GPL-3.0
#

# Returns 0 if the parameter with name $1 is set, otherwise returns 1.
is_set() {
    eval test '"${'$1'+0}"' = "0"
}

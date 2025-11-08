#!/usr/bin/env bash
# rginclude - ripgrep search in files matching glob patterns
# Usage: rginclude <pattern> <glob1> [glob2...] [rg-flags]
# Example: rginclude TODO '*.js' '*.ts'

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: rginclude <pattern> <glob1> [glob2...] [rg-flags]"
    echo "Example: rginclude TODO '*.js' '*.ts'"
    echo "Example: rginclude TODO '*.js' -l -i"
    exit 1
fi

pattern="$1"
shift

glob_args=()
rg_flags=()

for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
        rg_flags+=("$arg")
    else
        # Auto-wrap plain filenames (no wildcards or paths) with **/
        if [[ "$arg" != *'*'* && "$arg" != *'?'* && "$arg" != *'/'* ]]; then
            glob_args+=(-g "**/$arg")
        else
            glob_args+=(-g "$arg")
        fi
    fi
done

rg "$pattern" "${glob_args[@]}" "${rg_flags[@]}"

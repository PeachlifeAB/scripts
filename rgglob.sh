#!/usr/bin/env bash
# rgglob - ripgrep with glob pattern
# Usage: rgglob <pattern> <glob1> [glob2...] [rg-flags]
# Example: rgglob TODO '*.js' '*.ts' -l

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: rgglob <pattern> <glob1> [glob2...] [rg-flags]"
    echo "Example: rgglob TODO '*.js'"
    echo "Example: rgglob TODO '*.js' '*.ts' -l -i"
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
        glob_args+=(-g "$arg")
    fi
done

rg "$pattern" "${glob_args[@]}" "${rg_flags[@]}"

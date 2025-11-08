#!/usr/bin/env bash
# rgexclude - ripgrep search excluding patterns
# Usage: rgexclude <pattern> <exclude1> [exclude2...] [rg-flags]
# Example: rgexclude TODO '*.log' 'test/' 'node_modules/'

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: rgexclude <pattern> <exclude1> [exclude2...] [rg-flags]"
    echo "Example: rgexclude TODO '*.log' 'test/' 'node_modules/'"
    echo "Example: rgexclude TODO '*.log' -l -i"
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
        glob_args+=(-g "!$arg")
    fi
done

rg "$pattern" "${glob_args[@]}" "${rg_flags[@]}"

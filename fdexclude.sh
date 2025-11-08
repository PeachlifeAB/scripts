#!/usr/bin/env bash
# fdexclude - fd search excluding patterns
# Usage: fdexclude <pattern> <exclude1> [exclude2...] [fd-flags...]
# Example: fdexclude config '*.bak' 'test/' 'node_modules/'

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: fdexclude <pattern> <exclude1> [exclude2...] [fd-flags...]"
    echo "Example: fdexclude config '*.bak' 'test/' 'node_modules/'"
    echo "Example: fdexclude . 'docs/' '.git/' -X cat"
    exit 1
fi

pattern="$1"
shift

exclude_args=()
other_args=()
in_excludes=1

for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
        in_excludes=0
    fi
    if [[ $in_excludes -eq 1 ]]; then
        exclude_args+=(-E "$arg")
    else
        other_args+=("$arg")
    fi
done

fd "$pattern" "${exclude_args[@]}" "${other_args[@]}"

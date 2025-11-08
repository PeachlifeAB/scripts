#!/usr/bin/env bash
# fdinclude - fd search only specified extensions
# Usage: fdinclude <pattern> <ext1> [ext2...]
# Example: fdinclude config yaml json

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: fdinclude <pattern> <ext1> [ext2...]"
    echo "Example: fdinclude config yaml json"
    exit 1
fi

pattern="$1"
shift

ext_args=()
for ext in "$@"; do
    ext_args+=(-e "$ext")
done

fd "$pattern" "${ext_args[@]}"

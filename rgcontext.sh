#!/usr/bin/env bash
# rgcontext - ripgrep with context (default 5 lines)
# Usage: rgcontext <pattern> [lines]
# Example: rgcontext TODO 3

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: rgcontext <pattern> [lines]"
    exit 1
fi

lines=5
args=("$@")

# If last arg is a plain integer, treat it as context line count
last="${args[-1]}"
if [[ "$last" =~ ^[0-9]+$ ]] && [[ ${#args[@]} -gt 1 ]]; then
    lines="$last"
    unset 'args[-1]'
fi

rg -C "$lines" "${args[@]}"

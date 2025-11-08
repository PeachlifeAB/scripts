#!/bin/bash
# pp - Print real path and copy to clipboard
# Usage: pp [-g] <path>
# -g: Print path relative to git root

set -euo pipefail

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: ppath [-g] <path>"
    echo "Print real path and copy to clipboard"
    echo ""
    echo "Options:"
    echo "  -g    Print path relative to git root"
    echo "  -h, --help    Show this help message"
    exit 0
fi

if [[ "${1:-}" == "-g" ]]; then
    shift
    git_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
    if [[ -z "$git_root" ]]; then
        result=$(realpath "$@")
    else
        full_path=$(realpath "$@")
        result="${full_path#$git_root/}"
    fi
else
    result=$(realpath "$@")
fi

echo "$result" | pbcopy
echo "$result"

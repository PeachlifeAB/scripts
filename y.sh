#!/bin/bash
# y - Yazi file browser with cwd tracking
# Usage: y [yazi_args]

set -euo pipefail

tmp=$(mktemp -t "yazi-cwd.XXXXXX")
yazi "$@" --cwd-file="$tmp"
cwd=$(cat "$tmp")

if [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
    cd "$cwd"
fi

rm -f "$tmp"

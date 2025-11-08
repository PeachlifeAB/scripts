#!/bin/bash
# taill - Tail file or stdin to /tmp/junk and clipboard
# Usage: taill.sh <lines> [file]

set -euo pipefail

lines="${1:-}"
file="${2:-}"

if [[ -z "$lines" ]]; then
    echo "Usage: taill.sh <lines> [file]" >&2
    exit 2
fi

if [[ -n "$file" ]]; then
    tail -n "$lines" "$file" > /tmp/junk
    cb copy /tmp/junk
    exit 0
fi

tmp=$(mktemp -t "taill.stdin.XXXXXX")
trap 'rm -f "$tmp"' EXIT

cat >"$tmp"

first_line=$(head -n 1 "$tmp" | tr -d '\r')
rest_present=false
if [[ $(wc -l <"$tmp" | tr -d ' ') -gt 1 ]]; then
    rest_present=true
fi

if [[ "$rest_present" == false ]] && [[ -f "$first_line" ]]; then
    tail -n "$lines" "$first_line" > /tmp/junk
else
    tail -n "$lines" "$tmp" > /tmp/junk
fi

cb copy /tmp/junk

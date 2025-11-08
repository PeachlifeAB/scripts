#!/bin/bash
set -euo pipefail

# prs.sh - Parse URL with fjd, output is pipeable
# Usage: prs.sh <url> or echo "url" | prs.sh

if [[ $# -eq 0 ]]; then
    # Read from stdin if no arguments provided
    if [[ ! -t 0 ]]; then
        url=$(cat)
    else
        echo "Usage: prs.sh <url> or echo 'url' | prs.sh"
        exit 1
    fi
else
    url="$1"
fi

fjd --parse-url "$url"

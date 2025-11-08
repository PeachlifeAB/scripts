#!/bin/bash
# mvp - Move file with directory creation prompt
# Usage: mvp <source> <destination>

set -euo pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: mvp <source> <destination>"
    exit 1
fi

# Determine which directory to create
if [[ "$2" == */ ]]; then
    newdir="$2"
else
    newdir=$(dirname "$2")
fi

# Prompt for confirmation
read -p "Create dir $newdir? [Y/n] " -n 1 response
echo  # newline after single char input

# Default to Yes if empty, check if not 'n' or 'N'
if [[ -z "$response" ]] || [[ ! "$response" =~ ^[nN]$ ]]; then
    mkdir -p "$newdir" && mv "$1" "$2"
else
    echo "Cancelled."
    exit 1
fi

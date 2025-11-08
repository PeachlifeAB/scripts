#!/bin/bash
# d - Open daily notes in Ghostty with nvim
# Usage: d

set -euo pipefail

path="${NOTES_PATH}/Daily notes"
file="$path/$(date +%Y-%m-%d).md"
mkdir -p "$path"

# Add empty checkbox if last line doesn't have one
if ! tail -n 1 "$file" 2>/dev/null | grep -qE '^- \[ \]\s*$'; then
    echo "- [ ]  " >>"$file"
fi

# Open in Ghostty with nvim
open -n -a Ghostty --args --title=Daily -e fish -c "cd '$path' && nvim -n '+normal G' '+startinsert!' '$file'"

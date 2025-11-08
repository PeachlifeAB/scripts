#!/bin/bash
# openurl - Extract URL from clipboard and open in Safari
# Usage: openurl

set -euo pipefail

# Get clipboard content
clipboard=$(cb p)

# Extract URL using regex (http/https)
if [[ $clipboard =~ (https?://[^[:space:]]+) ]]; then
    url="${BASH_REMATCH[1]}"
    # Remove trailing punctuation (., !, ?, etc.)
    url="${url%[.,!?;:]}"
    echo "Opening: $url"
    open -a Safari "$url"
else
    echo "No URL found in clipboard"
    exit 1
fi

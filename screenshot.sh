#!/bin/bash
# screenshot - Capture window screenshot and copy path to clipboard
# Usage: screenshot

set -euo pipefail

# Generate filename with timestamp
FILE="$HOME/Desktop/screenshot-$(date +%Y%m%d-%H%M%S).png"

# Capture window screenshot
screencapture -w "$FILE"

# Copy file path to clipboard
echo -n "$FILE" | pbcopy

#!/bin/bash
# asc - Open aerospace config in Ghostty with nvim
# Usage: asc

set -euo pipefail

file="$HOME/.config/aerospace/aerospace.toml"
path="$(dirname "$file")"

# Open in Ghostty with nvim via hyprspace for floating center layout
hyprspace open -n -a Ghostty --args --title=Aerospace -e fish -c "cd '$path' && nvim '$file'" floating center

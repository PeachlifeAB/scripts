#!/bin/bash
# hammerspoon-cfg - Open hammerspoon config in Ghostty with nvim
# Usage: hammerspoon-cfg

set -euo pipefail

file="$HOME/.hammerspoon/init.lua"
path="$(dirname "$file")"

# Open in Ghostty with nvim via hyprspace for floating center layout
hyprspace open -n -a Ghostty --args --title=Hammerspoon -e fish -c "cd '$path' && nvim '$file'" floating center

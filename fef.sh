#!/bin/bash
# ff - Find and open any file in home directory with fzf
# Usage: ff

set -euo pipefail

# Open in Ghostty with fzf to find and open files
open -n -a Ghostty --args -e /opt/homebrew/bin/fish -l -c "cd ~ && fd | fzf --bind 'enter:execute(nvim {})+abort'"

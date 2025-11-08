#!/bin/bash
set -euo pipefail

# occ.sh - Run opencode with pattern-driven agent
# Usage: occ.sh <query> or cat file | occ

if [[ $# -eq 0 ]]; then
    # Read from stdin if no arguments provided
    if [[ ! -t 0 ]]; then
        query=$(cat)
    else
        echo "Usage: occ.sh <query> or cat file | occ"
        exit 1
    fi
else
    query="$*"
fi

# Temporarily use bash for opencode to ensure proper shell environment
original_shell="$SHELL"
export SHELL="/opt/homebrew/bin/bash"

opencode run --agent pattern-driven "$query"

# Restore original shell
export SHELL="$original_shell"

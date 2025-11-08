#!/bin/bash
set -euo pipefail

# aa.sh - Run opencode with plan agent and Claude Haiku model
# Usage: aa.sh <query> or cat file | aa

if [[ $# -eq 0 ]]; then
    # Read from stdin if no arguments provided
    if [[ ! -t 0 ]]; then
        query=$(cat)
    else
        echo "Usage: aa.sh <query> or cat file | aa"
        exit 1
    fi
else
    query="$*"
fi

# Temporarily use bash for opencode to ensure proper shell environment
original_shell="$SHELL"
export SHELL="/opt/homebrew/bin/bash"

opencode run --agent plan --model github-copilot/claude-haiku-4.5 "$query"

# Restore original shell
export SHELL="$original_shell"

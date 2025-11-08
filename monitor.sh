#!/bin/bash
# monitor.sh - Run a command repeatedly every 3 seconds
# Usage: monitor.sh <command> [args...]
#   monitor.sh git status
#   monitor.sh cat file.log
#   monitor.sh ls -la

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Usage: monitor.sh <command> [args...]"
    echo "Examples:"
    echo "  monitor.sh git status"
    echo "  monitor.sh cat file.log"
    echo "  monitor.sh ls -la"
    exit 1
fi

# Store the command and arguments
command_to_run="$*"

# Run the command in a loop with gum's spin for clean updates
while true; do
    clear
    
    # Show header with gum style
    gum style --foreground 212 --bold "Monitoring: $command_to_run"
    gum style --foreground 240 "Press Ctrl+C to stop | Updates every 3 seconds"
    echo ""
    
    # Show timestamp
    gum style --foreground 150 "Last update: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # Run the command
    eval "$command_to_run" || true
    
    # Wait 3 seconds
    sleep 3
done

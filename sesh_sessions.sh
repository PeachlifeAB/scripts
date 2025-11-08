#!/bin/bash
# sesh_sessions - Tmux session manager with fzf
# Usage: sesh_sessions

set -euo pipefail

# Get last numeric session
last_session=$(tmux ls 2>/dev/null | awk -F: '{print $1}' | tail -1 | grep -E '^[0-9]+$' || true)

# Build options array
options=("New session")
[[ -n "$last_session" ]] && options+=("$last_session")

# Add sesh list sessions
while IFS= read -r session; do
    options+=("$session")
done < <(sesh list -c 2>/dev/null || true)

# Show fzf menu
selection=$(printf "%s\n" "${options[@]}" | fzf \
    --height 30% \
    --border-label ' Pick session ' \
    --border \
    --prompt '⚡ ')

case "$selection" in
    "New session")
        # Clean up numeric-only detached sessions
        if tmux ls 2>/dev/null | grep -qE '^[0-9]+:'; then
            tmux ls 2>/dev/null | grep -E '^[0-9]+:' | awk -F: '{print $1}' | while read -r sess; do
                tmux kill-session -t "$sess" 2>/dev/null || true
            done
        fi
        # Start new session
        tmux
        ;;
    "$last_session")
        # Connect to the last numeric session
        if [[ -n "$last_session" ]]; then
            tmux attach-session -t "$last_session"
        fi
        ;;
    *)
        # Connect to existing session if one was selected
        if [[ -n "$selection" ]]; then
            sesh connect "$selection"
        fi
        ;;
esac

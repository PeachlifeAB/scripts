#!/bin/bash
SESSION=$(opencode-export --json --quiet | jq -r .session_id | head -n 1)
WINDOW_ID=$(aerospace list-windows --focused | awk '{print $1}')
CURRENT_DIR="$(pwd)"

echo "🪟 Current Window: $WINDOW_ID and session: $SESSION and path: $(CURRENT_DIR)"

hyprspace open -n -a Ghostty --args -e fish -c "cd '$CURRENT_DIR' && oc --session '$SESSION'"

sleep 0.5
aerospace close --window-id "$WINDOW_ID"

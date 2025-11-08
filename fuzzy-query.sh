#!/usr/bin/env bash
# fuzzy-query.sh - Interactive fuzzy search wrapper for aerc+notmuch
# Converts free-text search to regex patterns for substring matching
#
# Usage: Called by aerc :menu command
#   / = :menu -c 'fuzzy-query.sh' :query<Enter>
#
# Examples:
#   Input: "Marie Elm"           → Output: from:/.*Marie.*Elm.*/
#   Input: "from:test@example"   → Output: from:test@example (passthrough)
#   Input: "tag:unread"          → Output: tag:unread (passthrough)

# Show prompt to stderr (so it doesn't interfere with output)
printf "Search: " >&2
read -r query

# Empty query - exit with error code to signal cancellation to aerc
[ -z "$query" ] && exit 1

# Filter out escape sequences (ESC key produces ^[ or \x1b)
# Remove ANSI escape codes and control characters
query=$(echo "$query" | sed -E 's/\x1b|\^\[//g' | tr -d '\000-\037')

# If query became empty after filtering, exit with error to cancel
[ -z "$query" ] && exit 1

# If query already has notmuch prefix or regex delimiter, pass through as-is
# Prefixes: from, to, subject, tag, is, id, mid, thread, path, folder, attachment, mimetype, body, date, query
# Regex: /.../ pattern
if [[ "$query" =~ ^(from|to|subject|tag|is|id|mid|thread|path|folder|attachment|mimetype|body|date|query):|/.*/ ]]; then
    echo "$query"
    exit 0
fi

# Convert free-text to fuzzy regex for From field
# Replaces spaces with .* to match any characters in between
# "Marie Elm" → "Marie.*Elm" → from:/.*Marie.*Elm.*/
words=$(echo "$query" | sed -E 's/[[:space:]]+/.*/g')
echo "from:/.*${words}.*/"

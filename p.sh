#!/bin/bash

selection=$(fzf --scheme=path \
    --height 40% \
    --border \
    --preview 'bat -n --color=always {}' \
    --preview-window 'right,60%,border-left') || exit 1

if [[ -z $selection ]]; then
    exit 1
fi

if [[ -t 1 ]]; then
    printf '%s\n' "$selection"
    if command -v pbcopy >/dev/null 2>&1; then
        printf '%s' "$selection" | pbcopy
    fi
else
    printf '%s\n' "$selection"
fi

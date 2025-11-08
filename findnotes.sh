#!/bin/bash
# findnotes - Search and open notes with fzf preview
# Usage: findnotes

set -euo pipefail

NOTES_PATH="${NOTES_PATH:?NOTES_PATH not set}"

cd "$NOTES_PATH"

fd -e md | fzf \
    --preview 'bat --color=always {}' \
    --preview-window=right:50% \
    --bind 'enter:execute(nvim {})+abort'

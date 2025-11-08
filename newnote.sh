#!/bin/bash
# newnote - Create a new note in $NOTES_PATH with recursive folder navigation
# Usage: newnote

set -euo pipefail

NOTES_PATH="${NOTES_PATH:?NOTES_PATH not set}"

# Recursive folder navigator
navigate_folders() {
    local current_path="$1"
    
    # Get immediate subfolders (just names)
    cd "$current_path"
    local subfolders
    subfolders=$(ls -1d */ 2>/dev/null | sort || true)
    
    # If no subfolders, use this path
    if [ -z "$subfolders" ]; then
        echo "$current_path"
        return 0
    fi
    
    # Show subfolders in fzf
    local selected
    selected=$(echo "$subfolders" | CURRENT_PATH="$current_path" fzf \
        --preview 'ls "$CURRENT_PATH"/{} 2>&1 | head -20' \
        --preview-window=right:40% \
        --bind "ctrl-n:execute(mkdir -p \"$current_path/{q}\" && echo 'Created')+abort" \
        --header "Select subfolder or ESC to use current (Ctrl+N for new)" \
        || echo "")
    
    # If cancelled, use current path
    if [ -z "$selected" ]; then
        echo "$current_path"
        return 0
    fi
    
    # Recurse into selected folder (remove trailing slash)
    navigate_folders "$current_path/${selected%/}"
}

# Start navigation
target_dir=$(navigate_folders "$NOTES_PATH")

# Get note name
read -p "Enter note name (without .md): " note_name

if [ -z "$note_name" ]; then
    echo "Error: Note name cannot be empty"
    exit 1
fi

# Create note file path
note_file="$target_dir/${note_name}.md"

# Check if exists
if [ -f "$note_file" ]; then
    echo "Note already exists: $note_file"
    read -p "Open existing note? (y/n) " -n 1 response
    echo
    if [[ ! $response =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    # Create with Obsidian template
    {
        echo "---"
        echo "created_at: $(date -u +%Y-%m-%dT%H:%M:%S)Z"
        echo "id: $(uuidgen | tr '[:upper:]' '[:lower:]')"
        echo "aliases: []"
        echo "tags: []"
        echo "---"
        echo ""
        echo "# $note_name"
        echo ""
    } > "$note_file"
fi

# Open in nvim
nvim "$note_file"

#!/bin/bash
# note - Browse, open, create, or quick-create notes
# Usage: note
#   enter    open selected note in nvim
#   ctrl-n   create new note (folder nav + name prompt)
#   ctrl-t   create temporary note in /tmp/quicknotes
#   ctrl-d   open today's daily note in Ghostty

set -euo pipefail

NOTES_PATH="${NOTES_PATH:?NOTES_PATH not set}"

_new_note() {
    local current_path="$1"
    cd "$current_path"
    local subfolders
    subfolders=$(ls -1d */ 2>/dev/null | sort || true)

    if [ -z "$subfolders" ]; then
        echo "$current_path"
        return 0
    fi

    local selected
    selected=$(echo "$subfolders" | CURRENT_PATH="$current_path" fzf \
        --preview 'ls "$CURRENT_PATH"/{} 2>&1 | head -20' \
        --preview-window=right:40% \
        --header "Select subfolder or ESC to use current" \
        || echo "")

    if [ -z "$selected" ]; then
        echo "$current_path"
        return 0
    fi

    _new_note "$current_path/${selected%/}"
}

case "${1:-browse}" in
    --new)
        target_dir=$(_new_note "$NOTES_PATH")
        read -p "Enter note name (without .md): " note_name </dev/tty
        if [ -z "$note_name" ]; then
            echo "Error: Note name cannot be empty" >&2
            exit 1
        fi
        note_file="$target_dir/${note_name}.md"
        if [ -f "$note_file" ]; then
            echo "Note already exists: $note_file" >&2
            read -p "Open existing note? (y/n) " -n 1 response </dev/tty
            echo >&2
            [[ $response =~ ^[Yy]$ ]] || exit 1
        else
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
        nvim "$note_file"
        ;;

    --temp)
        dir="/tmp/quicknotes"
        mkdir -p "$dir"
        nvim "$dir/note-$(date +%Y%m%d-%H%M%S).md"
        ;;

    --daily)
        path="${NOTES_PATH}/Daily notes"
        file="$path/$(date +%Y-%m-%d).md"
        mkdir -p "$path"
        if ! tail -n 1 "$file" 2>/dev/null | grep -qE '^- \[ \]\s*$'; then
            echo "- [ ]  " >>"$file"
        fi
        nvim -n "+normal G" "+startinsert!" "$file"
        ;;

    browse)
        cd "$NOTES_PATH"
        fd -e md | fzf \
            --preview 'bat --color=always {}' \
            --preview-window=right:50% \
            --header 'enter: open  ctrl-n: new  ctrl-t: temp  ctrl-d: daily' \
            --bind "enter:become(nvim {})" \
            --bind "ctrl-n:become(\"$0\" --new)" \
            --bind "ctrl-t:become(\"$0\" --temp)" \
            --bind "ctrl-d:become(/Users/davidaberg/Developer/scripts/note.sh --daily)"
        ;;
esac

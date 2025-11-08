#!/bin/bash
set -euo pipefail

symlink_file() {
    local exe_path="$1"
    local full_path
    full_path=$(readlink -f "$exe_path")

    if [[ ! -f "$full_path" ]]; then
        echo "Error: File not found: $exe_path"
        return 1
    fi

    chmod +x "$full_path"
    local filename
    filename=$(basename "$full_path" | sed 's/\.[^.]*$//')
    ln -sf "$full_path" "$HOME/.local/bin/$filename"
    echo "Symlinked: $HOME/.local/bin/$filename → $full_path"
}

if [[ $# -eq 1 && "$1" == "--all" ]]; then
    script_dir="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
    for f in "$script_dir"/*.sh; do
        symlink_file "$f"
    done
elif [[ $# -eq 1 ]]; then
    symlink_file "$1"
else
    echo "Usage: symlink.sh <executable_path>"
    echo "       symlink.sh --all"
    exit 1
fi

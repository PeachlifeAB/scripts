#!/bin/bash
# quicknote - Open neovim with new markdown note
# Usage: quicknote

set -euo pipefail

NOTES_DIR="/tmp/quicknotes"
mkdir -p "$NOTES_DIR"

FILENAME="note-$(date +%Y%m%d-%H%M%S).md"
nvim "$NOTES_DIR/$FILENAME"

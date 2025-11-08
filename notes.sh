#!/bin/bash
# notes - Open notes directory with telescope in nvim
# Usage: notes

set -euo pipefail

cd "$NOTES_PATH" && nvim -c ':Telescope find_files'

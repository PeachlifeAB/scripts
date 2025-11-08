#!/usr/bin/env bash
# Add a GitHub repo to the shared references store.
# Usage: references-add <owner/repo> [target-name]
#
# Examples:
#   references-add zsh-users/zsh-syntax-highlighting
#   references-add zsh-users/zsh-syntax-highlighting zsh-syntax

set -euo pipefail

REFCODE_DIR="$HOME/Developer/references"

if [[ $# -lt 1 ]]; then
  echo "Usage: references-add <owner/repo> [target-name]" >&2
  exit 1
fi

REPO="$1"
TARGET="${2:-${REPO##*/}}"
DEST="$REFCODE_DIR/$TARGET"

if [[ -e "$DEST" ]]; then
  echo "Already exists: $DEST" >&2
  exit 1
fi

gh repo clone "$REPO" "$DEST"
echo "Cloned $REPO -> $DEST"

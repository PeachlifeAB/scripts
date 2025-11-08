#!/bin/bash
set -euo pipefail

show_help() {
  cat << 'EOF'
USAGE:
  syncstagedto <destination_path>

DESCRIPTION:
  Copies staged git files to destination repo, preserving directory structure.

EXAMPLE:
  syncstagedto ~/Work/iOS-org/

EOF
}

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

if [[ -z "${1:-}" ]]; then
  echo "Error: destination path required" >&2
  echo "Run 'syncstagedto --help' for usage information" >&2
  exit 1
fi

DESTINATION_PATH="$1"

if [[ ! -d "$DESTINATION_PATH" ]]; then
  echo "Error: '$DESTINATION_PATH' is not a valid directory" >&2
  exit 1
fi

# Get git root directory
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ -z "$GIT_ROOT" ]]; then
  echo "Error: Not in a git repository" >&2
  exit 1
fi

# Sync staged files from git root to destination, preserving paths
git diff --staged --name-only | rsync -av --files-from=- "$GIT_ROOT" "$DESTINATION_PATH"

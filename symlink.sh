#!/bin/bash
set -euo pipefail

resolve_path() {
  local path="$1"
  if [[ -d "$path" ]]; then
    (cd "$path" && pwd)
  else
    (cd "$(dirname "$path")" && printf '%s/%s\n' "$(pwd)" "$(basename "$path")")
  fi
}

symlink_file() {
  local exe_path="$1"
  local destination="$2"
  local full_path
  full_path="$(resolve_path "$exe_path")"

  if [[ ! -f "$full_path" ]]; then
    echo "Error: File not found: $exe_path" >&2
    return 1
  fi

  mkdir -p "$destination"
  chmod +x "$full_path"

  local filename
  filename="$(basename "$full_path" | sed 's/\.[^.]*$//')"

  ln -sf "$full_path" "$destination/$filename"
  echo "Symlinked: $destination/$filename → $full_path"
}

destination="$HOME/.local/bin"

mode=""
exe_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  -d | --destination)
    if [[ $# -lt 2 ]]; then
      echo "Error: Missing value for $1" >&2
      exit 1
    fi
    destination="$2"
    shift 2
    ;;
  --all)
    mode="all"
    shift
    ;;
  -*)
    echo "Error: Unknown option: $1" >&2
    exit 1
    ;;
  *)
    if [[ -n "$exe_path" || "$mode" == "all" ]]; then
      echo "Error: Invalid arguments" >&2
      exit 1
    fi
    exe_path="$1"
    mode="single"
    shift
    ;;
  esac
done

if [[ "$mode" == "all" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  for f in "$script_dir"/*.sh; do
    [[ -e "$f" ]] || continue
    symlink_file "$f" "$destination"
  done
elif [[ "$mode" == "single" ]]; then
  symlink_file "$exe_path" "$destination"
else
  echo "Usage: symlink.sh [--destination <dir>] <executable_path>"
  echo "       symlink.sh [--destination <dir>] --all"
  echo "       symlink.sh [-d <dir>] <executable_path>"
  echo "       symlink.sh [-d <dir>] --all"
  exit 1
fi

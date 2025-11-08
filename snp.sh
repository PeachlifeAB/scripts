#!/usr/bin/env bash
set -euo pipefail

show_help() {
    cat <<EOF
snp [options]

Create a timestamped snapshot of the current git repository.

Options:
    -e, --exclude PATTERN    Exclude folder/file pattern (can be used multiple times)
    -h, --help               Show this help

Examples:
    snp
    snp -e references
    snp -e Aerospace --exclude references
    snp -e node_modules -e .build -e dist

EOF
    exit 0
}

declare -a excludes=()

while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        show_help
        ;;
    -e | --exclude)
        [[ -n "${2:-}" ]] || {
            echo "Error: $1 requires a pattern" >&2
            exit 1
        }
        excludes+=("$2")
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        shift
        ;;
    esac
done

date=$(date "+%Y%m%d%H%M%S")
groot="$(git rev-parse --show-toplevel)"
proj="$(basename "$groot")"
dir="../snapshots/$proj/$date"
mkdir -p "$dir"

rsync_args=()
for pattern in "${excludes[@]}"; do
    rsync_args+=(--exclude="$pattern")
done

rsync -a "${rsync_args[@]}" "$groot"/ "$dir"/

echo "snapshot created at:"
echo "$dir"

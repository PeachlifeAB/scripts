#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat >&2 <<EOF
Usage:
    $(basename "$0") <0-100> [comment...]
    $(basename "$0") view
EOF
}

config_home="${XDG_CONFIG_HOME:-"$HOME/.config"}"
dir="$config_home/healthscore"
file="$dir/data.csv"

if [[ "${1:-}" == "view" ]]; then
    exec csview "$file"
fi

if [[ "${1:-}" == "edit" ]]; then
    exec nvim "$file"
fi

[[ $# -ge 1 ]] || {
    usage
    exit 1
}

score="$1"
shift || true

if [[ ! "$score" =~ ^[0-9]{1,3}$ ]] || ((score < 0 || score > 100)); then
    usage
    echo "Error: score must be an integer between 0 and 100." >&2
    exit 1
fi

comment="${*:-}"
comment="${comment//$'\r'/ }"
comment="${comment//$'\n'/ }"
comment="${comment//\"/\"\"}" # CSV escaping for quotes

mkdir -p "$dir"

if [[ ! -f "$file" ]]; then
    echo 'date,score,comment' >"$file"
fi

timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
printf '"%s",%s,"%s"\n' "$timestamp" "$score%" "$comment" >>"$file"

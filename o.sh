#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

fzf -m --print0 >"$tmp" || exit 0
[[ -s "$tmp" ]] || exit 0

xargs -0 nvim <"$tmp"

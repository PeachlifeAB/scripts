#!/usr/bin/env bash
# oMLX model switcher - pick a model with fzf then load it
set -euo pipefail

OMLX_API_KEY="${OMLX_API_KEY:?Set OMLX_API_KEY in your environment}"
OMLX_HOST="${OMLX_HOST:?Set OMLX_HOST in your environment}"

for cmd in curl jq fzf; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Required: $cmd" >&2; exit 1; }
done

model=$(curl -s -H "Authorization: Bearer $OMLX_API_KEY" "$OMLX_HOST/v1/models" \
  | jq -r '.data[].id' \
  | fzf --prompt="oMLX model> " --height=~20 --reverse) || exit 0

[ -z "$model" ] && exit 0

cookie_jar=$(mktemp)
trap 'rm -f "$cookie_jar"' EXIT

curl -s -c "$cookie_jar" -X POST -H "Content-Type: application/json" \
  -d "{\"api_key\":\"$OMLX_API_KEY\"}" "$OMLX_HOST/admin/api/login" > /dev/null

result=$(curl -s -b "$cookie_jar" -X POST "$OMLX_HOST/admin/api/models/$model/load")

if echo "$result" | jq -e '.status == "ok"' > /dev/null 2>&1; then
  echo "Loaded: $model"
else
  echo "Failed: $(echo "$result" | jq -r '.detail // .message // "unknown error"')" >&2
  exit 1
fi

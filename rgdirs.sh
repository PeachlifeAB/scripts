#!/usr/bin/env bash
# rgdirs - show unique parent directories of rg matches
# Usage: rgdirs [rg-args]

results=$(rg -l "$@")
if [[ -n "$results" ]]; then
    echo "$results" | xargs -n1 dirname | sort -u
fi

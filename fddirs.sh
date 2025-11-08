#!/usr/bin/env bash
# fddirs - show unique parent directories of fd matches
# Usage: fddirs [fd-args]

results=$(fd "$@")
if [[ -n "$results" ]]; then
    echo "$results" | xargs -n1 dirname | sort -u
fi

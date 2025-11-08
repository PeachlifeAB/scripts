#!/usr/bin/env bash
# rgcode - ripgrep search only code files (exclude docs/config)
# Usage: rgcode [rg-args]

rg "$@" -T md -T markdown -T txt -T json -T yaml -T toml -T xml -T csv

#!/usr/bin/env bash
# rgcount - ripgrep count matches per file
# Usage: rgcount [rg-args]

rg -c "$@"

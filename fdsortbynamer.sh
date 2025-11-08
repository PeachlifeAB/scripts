#!/usr/bin/env bash
# fdsortbynamer - fd sorted by name (Z-A)
# Usage: fdsortbynamer [fd-args]

fd "$@" | sort -r

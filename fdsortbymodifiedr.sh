#!/usr/bin/env bash
# fdsortbymodifiedr - fd sorted by modified time (oldest first)
# Usage: fdsortbymodifiedr [fd-args]

fd "$@" -X ls -lt

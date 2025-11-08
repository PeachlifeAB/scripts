#!/usr/bin/env bash
# fdsortbymodified - fd sorted by modified time (newest last)
# Usage: fdsortbymodified [fd-args]

fd "$@" -X ls -ltr

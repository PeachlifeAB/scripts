#!/usr/bin/env bash
# fdsortbyname - fd sorted by name (A-Z)
# Usage: fdsortbyname [fd-args]

fd "$@" | sort

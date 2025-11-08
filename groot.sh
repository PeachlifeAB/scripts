#!/usr/bin/env bash
root="$(git rev-parse --show-toplevel)" || exit 1
cd -P -- "$root" || exit 1

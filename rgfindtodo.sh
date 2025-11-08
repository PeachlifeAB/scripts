#!/usr/bin/env bash
# rgfindtodo - find TODOs, FIXMEs, HACKs with context
# Usage: rgfindtodo [rg-args]

rg 'TODO|FIXME|HACK|XXX|NOTE' -C 2 "$@"

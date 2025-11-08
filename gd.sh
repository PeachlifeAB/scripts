#!/bin/bash
# gd - Show git diff with pager disabled
# Usage: gd [flags...]

git --no-pager diff "$@"

#!/bin/bash
# jjd - Show git-style diff for jj (Jujutsu) working copy
# Usage: jjd [flags...]

jj diff --no-pager --git "$@"

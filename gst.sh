#!/bin/bash
# prints git changes in colored numbers
#
# Input: "2 files changed, 1 deletions(-)"
# Output: 2 +0 -1
# Input: "299 files changed, 3209 deletions(-)"
# Output: 299 +0 -3209
# Input: "2 files changed, 988 insertions(+)"
# Output: 2 +988 -0
# Input: "5000 files changed, 988 insertions(+), 3 deletions(-)"
# Output: 5000 +988 -3
#
yellow=$'\e[33m'
green=$'\e[32m'
red=$'\e[31m'
reset=$'\e[0m'

git diff --shortstat | sd '^\s*(\d+)\D+(?:(\d+)\D+ins\w*)?\D*(?:(\d+)\D+del\w*)?.*$' "$yellow\$1$reset $green+\$2$reset $red-\$3$reset" | sd '([+-])(\x1b\[0m)' '${1}0$2'

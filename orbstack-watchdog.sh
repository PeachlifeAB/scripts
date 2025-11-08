#!/bin/bash
export PATH="$HOME/.orbstack/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# If docker ps does not respond within 8s, OrbStack is hung
timeout 8 docker ps >/dev/null 2>&1
[ $? -eq 124 ] || exit 0

pkill -9 -f "OrbStack Helper"
pkill -9 -x "OrbStack"
sleep 5
orb start

#!/usr/bin/env bash
set -euo pipefail

docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}' | docker-color-output -c "$HOME/.config/docker-color-output/config.json"

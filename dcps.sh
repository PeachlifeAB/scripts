#!/usr/bin/env bash
set -euo pipefail

docker compose ps --format 'table {{.Name}}\t{{.Status}}' | docker-color-output -c "$HOME/.config/docker-color-output/config.json"

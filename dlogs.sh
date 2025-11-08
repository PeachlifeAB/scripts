#!/usr/bin/env bash
set -euo pipefail

docker logs "$@" | docker-color-output -c "$HOME/.config/docker-color-output/config.json"

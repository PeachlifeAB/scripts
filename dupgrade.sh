#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Docker"
docker compose pull
docker compose build --no-cache
docker compose down
docker compose up -d --remove-orphans

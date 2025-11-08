#!/usr/bin/env bash
set -euo pipefail

docker compose pull
docker compose build --no-cache
docker compose down
docker compose up -d --remove-orphans

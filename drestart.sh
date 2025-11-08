#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Docker"
docker compose down
docker compose up -d

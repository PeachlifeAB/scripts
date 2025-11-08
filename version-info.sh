#!/usr/bin/env bash
# version-info.sh - Display version and commit hash for all running services

set -euo pipefail

echo "=== Telemetry Service Version Info ==="
echo ""

# Get version from git
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

echo "Repository:"
echo "  Version: ${VERSION}"
echo "  Commit:  ${COMMIT_HASH}"
echo "  Branch:  ${BRANCH}"
echo ""

# Check if services are running
if ! docker compose ps --services --filter "status=running" &>/dev/null; then
    echo "ERROR: No services running. Start with: docker compose up -d"
    exit 1
fi

echo "Running Services:"
docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Display labels from containers
echo "Container Labels (version info):"
for service in vector loki grafana; do
    container="telemetry-${service}"
    if docker inspect "${container}" &>/dev/null; then
        echo "  ${service}:"
        docker inspect "${container}" --format '    version: {{index .Config.Labels "app.version"}}' 2>/dev/null || echo "    version: not set"
        docker inspect "${container}" --format '    commit:  {{index .Config.Labels "app.commit"}}' 2>/dev/null || echo "    commit: not set"
    fi
done
echo ""

# Health status
echo "Health Checks:"
docker compose ps --format "json" | jq -r '.[] | "  \(.Service): \(.Health)"' 2>/dev/null || echo "  (jq not available - install for JSON parsing)"
echo ""

echo "=== Quick Debug Commands ==="
echo "  Check all logs:       docker compose logs --tail=50"
echo "  Check service logs:   docker compose logs <service> --tail=50"
echo "  Restart service:      docker compose restart <service>"
echo "  Full restart:         docker compose down && VERSION=${VERSION} COMMIT_HASH=${COMMIT_HASH} docker compose up -d"

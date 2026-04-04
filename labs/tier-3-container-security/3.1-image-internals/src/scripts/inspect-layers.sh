#!/bin/bash
# Script to inspect image layers and find hidden content
set -euo pipefail
IMAGE="${1:-webapp-internals:latest}"
echo "=== Image History (shows deleted files still in layers) ==="
docker history --no-trunc "$IMAGE"
echo ""
echo "=== Extracting layers to find secrets ==="
docker save "$IMAGE" | tar -xf - -C /tmp/image-export/
for layer in /tmp/image-export/*/layer.tar; do
    echo "--- Checking layer: $layer ---"
    tar -tf "$layer" 2>/dev/null | grep -i "secret\|password\|key\|\.env" || true
done

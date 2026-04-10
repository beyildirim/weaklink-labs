#!/bin/bash
# Reset the seeded safe image in the local registry so "latest" starts clean.
# This simulates the initial state: you pull an image and it is safe.

set -euo pipefail

REGISTRY="registry:5000"

echo "[*] Waiting for registry..."
for i in $(seq 1 30); do
    if curl -sf "http://${REGISTRY}/v2/" > /dev/null 2>&1; then
        echo "[+] Registry is up."
        break
    fi
    sleep 1
done

echo "[*] Restoring safe image tags in the local registry..."
crane --insecure copy "${REGISTRY}/webapp:1.0.0" "${REGISTRY}/webapp:latest" >/tmp/0.3-crane-copy.log 2>&1

echo "[*] Recording safe image digest..."
SAFE_DIGEST=$(crane --insecure digest "${REGISTRY}/webapp:1.0.0" 2>/dev/null)
echo "${SAFE_DIGEST}" > /lab/safe-digest.txt
echo "[+] Safe image digest: ${SAFE_DIGEST}"

echo "[+] Registry setup complete."
echo "    Image: ${REGISTRY}/webapp:latest"
echo "    Image: ${REGISTRY}/webapp:1.0.0"

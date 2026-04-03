#!/bin/bash
# Build and push the safe image to the local registry, tagged as "latest".
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

echo "[*] Building safe image..."
cd /lab/src/app
docker build -t "${REGISTRY}/webapp:latest" -t "${REGISTRY}/webapp:1.0.0" .

echo "[*] Pushing safe image to local registry..."
docker push "${REGISTRY}/webapp:latest"
docker push "${REGISTRY}/webapp:1.0.0"

echo "[*] Recording safe image digest..."
SAFE_DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' "${REGISTRY}/webapp:latest" 2>/dev/null | cut -d@ -f2)
echo "${SAFE_DIGEST}" > /lab/safe-digest.txt
echo "[+] Safe image digest: ${SAFE_DIGEST}"

echo "[+] Registry setup complete."
echo "    Image: ${REGISTRY}/webapp:latest"
echo "    Image: ${REGISTRY}/webapp:1.0.0"

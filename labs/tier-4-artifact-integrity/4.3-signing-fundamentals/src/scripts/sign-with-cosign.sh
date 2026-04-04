#!/bin/bash
set -euo pipefail
IMAGE="${1:-registry:5000/webapp:1.0.0}"
echo "[*] Generating a cosign key pair..."
cosign generate-key-pair --output-key-prefix=weaklink
echo "[*] Signing image: $IMAGE"
cosign sign --key=weaklink.key "$IMAGE"
echo "[*] Verifying signature..."
cosign verify --key=weaklink.pub "$IMAGE"
echo "[+] Image signature verified successfully."

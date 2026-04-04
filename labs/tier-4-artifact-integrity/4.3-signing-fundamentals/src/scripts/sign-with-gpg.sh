#!/bin/bash
set -euo pipefail
ARTIFACT="${1:-app-release.tar.gz}"
echo "[*] Generating GPG key for demo..."
gpg --batch --gen-key << GPGEOF
Key-Type: RSA
Key-Length: 2048
Name-Real: WeakLink Demo
Name-Email: demo@weaklink.local
Expire-Date: 0
%no-protection
GPGEOF
echo "[*] Signing artifact: $ARTIFACT"
gpg --armor --detach-sign "$ARTIFACT"
echo "[*] Verifying signature..."
gpg --verify "${ARTIFACT}.asc" "$ARTIFACT"
echo "[+] Signature verified."

#!/bin/bash
set -euo pipefail
echo "[*] Downloading demo-lib and checking integrity..."
PACKAGE_URL=$(curl -s http://pypi-private:8080/simple/demo-lib/ | grep -oP 'href="\K[^"]+' | tail -1)
if [ -n "$PACKAGE_URL" ]; then
    curl -sO "http://pypi-private:8080/${PACKAGE_URL}"
    FILENAME=$(basename "$PACKAGE_URL" | cut -d'#' -f1)
    HASH=$(sha256sum "$FILENAME" | cut -d' ' -f1)
    echo "[+] Downloaded: $FILENAME"
    echo "[+] SHA256: $HASH"
    echo ""
    echo "    Add this to requirements.txt for integrity pinning:"
    echo "    demo-lib==1.0.0 --hash=sha256:${HASH}"
else
    echo "[-] demo-lib not found on registry"
fi

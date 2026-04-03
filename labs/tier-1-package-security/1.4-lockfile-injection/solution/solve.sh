#!/bin/bash
#
# Solution for Lab 1.4: Lockfile Injection
# Run inside the workstation container: docker exec -it lab-1.4-workstation bash < solution/solve.sh
#

set -e

echo "[*] Removing compromise marker..."
rm -f /tmp/lockfile-pwned

echo "[*] Regenerating lockfile from source..."
cd /app/project
pip-compile --generate-hashes \
    --index-url http://pypi:8080/simple/ \
    --trusted-host pypi \
    requirements.in \
    --output-file requirements.txt 2>/dev/null

echo "[*] Verifying lockfile integrity..."
bash verify-lockfile.sh requirements.in requirements.txt

echo "[+] Done. Run 'weaklink verify 1.4' to confirm."

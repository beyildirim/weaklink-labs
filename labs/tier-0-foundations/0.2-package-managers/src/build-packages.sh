#!/bin/bash
# Build source distributions for both packages and place them in the PyPI server directory.
set -euo pipefail

echo "[*] Building packages..."

cd /packages/safe-utils
python setup.py sdist --dist-dir /data/packages/ 2>/dev/null
echo "[+] Built safe-utils"

cd /packages/malicious-utils
python setup.py sdist --dist-dir /data/packages/ 2>/dev/null
echo "[+] Built malicious-utils"

echo "[+] All packages built. Contents of /data/packages/:"
ls -la /data/packages/

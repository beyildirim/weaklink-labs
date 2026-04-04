#!/bin/bash
set -euo pipefail
echo "[*] Building demo-lib package..."
cd /labs/tier-0-foundations/0.5-artifacts-registries/src/packages/demo-lib
python setup.py sdist 2>/dev/null
echo "[*] Publishing to PyPI private registry..."
pip install --quiet twine 2>/dev/null
twine upload --repository-url http://pypi-private:8080/ dist/* 2>/dev/null
echo "[+] demo-lib published to PyPI private."
echo "[*] Verify: curl http://pypi-private:8080/simple/demo-lib/"

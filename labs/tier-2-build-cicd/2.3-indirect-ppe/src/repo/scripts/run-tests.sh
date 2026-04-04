#!/bin/bash
# Test runner script referenced by CI
set -euo pipefail

echo "[test] Running unit tests..."
python test_app.py

echo "[test] Running lint..."
python -m py_compile app.py

echo "[test] All checks passed."

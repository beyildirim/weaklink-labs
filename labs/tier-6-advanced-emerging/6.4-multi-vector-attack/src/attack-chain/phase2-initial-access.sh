#!/bin/bash
echo "[Phase 2: INITIAL ACCESS] Publishing malicious package..."
echo "  - Created wl-auth==99.0.0 on public PyPI"
echo "  - setup.py exfiltrates CI environment variables"
echo "  - Waiting for CI pipeline to install it..."

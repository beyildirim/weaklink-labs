#!/bin/bash
# Build acme-auth packages for both registries.
# Called during Docker image build.

set -euo pipefail

PACKAGES_DIR="/build/packages"
PRIVATE_PACKAGES="/packages/private"
PUBLIC_PACKAGES="/packages/public"

mkdir -p "$PRIVATE_PACKAGES" "$PUBLIC_PACKAGES"

echo "=== Building legitimate acme-auth 1.0.0 for private registry ==="
cd "${PACKAGES_DIR}/acme-auth-1.0.0"
python setup.py sdist bdist_wheel -q
cp dist/* "$PRIVATE_PACKAGES/"

echo "=== Building malicious acme-auth 99.0.0 for public registry ==="
cd "${PACKAGES_DIR}/acme-auth-99.0.0"
# Build as sdist only (not wheel) -- setup.py code only runs when installing from sdist
python setup.py sdist -q
cp dist/* "$PUBLIC_PACKAGES/"

echo "=== Done ==="
echo "Private packages:"
ls -la "$PRIVATE_PACKAGES/"
echo ""
echo "Public packages:"
ls -la "$PUBLIC_PACKAGES/"

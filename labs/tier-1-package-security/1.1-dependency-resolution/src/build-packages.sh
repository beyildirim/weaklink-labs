#!/bin/bash
# Build all packages into distributable sdist/wheel archives.
# Called during Docker image build to pre-populate the PyPI servers.

set -euo pipefail

PACKAGES_DIR="/build/packages"
PRIVATE_PACKAGES="/packages/private"
PUBLIC_PACKAGES="/packages/public"

mkdir -p "$PRIVATE_PACKAGES" "$PUBLIC_PACKAGES"

echo "=== Building packages for private registry ==="

# Legitimate packages go to private registry
for pkg in logging-helper-1.0.0 internal-utils-1.0.0 data-processor-2.0.0; do
    echo "  Building ${pkg}..."
    cd "${PACKAGES_DIR}/${pkg}"
    python setup.py sdist bdist_wheel -q
    cp dist/* "$PRIVATE_PACKAGES/"
done

echo "=== Building packages for public registry ==="

# The fake higher-version package goes to public registry
for pkg in internal-utils-99.0.0; do
    echo "  Building ${pkg}..."
    cd "${PACKAGES_DIR}/${pkg}"
    python setup.py sdist bdist_wheel -q
    cp dist/* "$PUBLIC_PACKAGES/"
done

echo "=== Done ==="
echo "Private packages:"
ls -la "$PRIVATE_PACKAGES/"
echo ""
echo "Public packages:"
ls -la "$PUBLIC_PACKAGES/"

#!/bin/bash
# Verification script for Lab 0.5: Artifacts & Registries
set -uo pipefail

PYPI_PRIVATE="http://pypi-private:8080"
VERDACCIO="http://verdaccio:4873"
WORKSPACE_DIR="/workspace/artifact-demo"
REFERENCE_TARBALL="${WORKSPACE_DIR}/reference/demo_lib-1.0.0.tar.gz"

PASS=0
FAIL=0

check() {
    local description="$1"
    local result="$2"
    if [ "$result" -eq 0 ]; then
        echo "  PASS: ${description}"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: ${description}"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "=== Lab 0.5 Verification: Artifacts & Registries ==="
echo ""

# Check 1: PyPI private is running
if curl -sf "${PYPI_PRIVATE}/simple/" > /dev/null 2>&1; then
    check "PyPI private registry is running" 0
else
    check "PyPI private registry is running" 1
fi

# Check 2: Verdaccio is running
if curl -sf "${VERDACCIO}/-/ping" > /dev/null 2>&1; then
    check "Verdaccio npm registry is running" 0
else
    check "Verdaccio npm registry is running" 1
fi

# Check 3: demo-lib package exists on PyPI private
DEMO_LIB=$(curl -sf "${PYPI_PRIVATE}/simple/demo-lib/" 2>/dev/null)
if echo "$DEMO_LIB" | grep -q "demo.lib" 2>/dev/null; then
    check "demo-lib package is published to PyPI private" 0
else
    check "demo-lib package is published to PyPI private" 1
fi

# Check 4: OCI registry is running
if curl -sf "http://registry:5000/v2/" > /dev/null 2>&1; then
    check "OCI container registry is running" 0
else
    check "OCI container registry is running" 1
fi

# Check 5: Reference artifact exists locally
if [ -f "${REFERENCE_TARBALL}" ]; then
    check "Reference artifact exists for known-good demo-lib" 0
else
    check "Reference artifact exists for known-good demo-lib" 1
fi

# Check 6: requirements.txt pins demo-lib with a hash
if grep -q '^demo-lib==1.0.0 --hash=sha256:' "${WORKSPACE_DIR}/requirements.txt" 2>/dev/null; then
    check "requirements.txt pins demo-lib with a SHA256 hash" 0
else
    check "requirements.txt pins demo-lib with a SHA256 hash" 1
fi

# Check 7: The pinned hash matches the known-good artifact
if [ -f "${REFERENCE_TARBALL}" ] && [ -f "${WORKSPACE_DIR}/requirements.txt" ]; then
    EXPECTED_HASH=$(sha256sum "${REFERENCE_TARBALL}" | awk '{print $1}')
    if grep -q "${EXPECTED_HASH}" "${WORKSPACE_DIR}/requirements.txt" 2>/dev/null; then
        check "Pinned hash matches the known-good artifact" 0
    else
        check "Pinned hash matches the known-good artifact" 1
    fi
else
    check "Pinned hash matches the known-good artifact" 1
fi

# Check 8: The learner captured a hash mismatch when installing from the registry
if grep -qi "do not match the hashes" "${WORKSPACE_DIR}/hash-check.log" 2>/dev/null; then
    check "Hash verification blocked the tampered registry artifact" 0
else
    check "Hash verification blocked the tampered registry artifact" 1
fi

echo ""
echo "=== Results ==="
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"
echo ""
if [ "${FAIL}" -eq 0 ]; then
    echo "  ALL CHECKS PASSED -- Lab 0.5 complete!"
    exit 0
else
    echo "  Some checks failed."
    exit 1
fi

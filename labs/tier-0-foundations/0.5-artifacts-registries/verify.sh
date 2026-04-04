#!/bin/bash
# Verification script for Lab 0.5: Artifacts & Registries
set -uo pipefail

PYPI_PRIVATE="http://pypi-private:8080"
VERDACCIO="http://verdaccio:4873"

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

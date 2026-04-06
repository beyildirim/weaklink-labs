#!/bin/bash
#
# Verification script for Lab 4.3: Signing Fundamentals
# Checks that the user signed an image and set up verification enforcement.
#

set -uo pipefail

PASS=0
FAIL=0

check() {
    local description="$1"
    local result
    result=$(bash -c "$2" 2>&1)
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        echo "  [PASS] $description"
        ((PASS++))
    else
        echo "  [FAIL] $description"
        echo "         $result"
        ((FAIL++))
    fi
}

echo ""
echo "  Verifying Lab 4.3: Signing Fundamentals"
echo "  ========================================="
echo ""

# Check 1: cosign key pair exists
check "Cosign key pair was generated" \
    "test -f /app/cosign.key && test -f /app/cosign.pub"

# Check 2: Image was signed (signature exists in registry)
check "Image has been signed (cosign verify succeeds)" \
    "cosign verify --allow-http-registry --allow-insecure-registry --key /app/cosign.pub registry:5000/weaklink-app:signed 2>/dev/null | grep -q 'Verified OK\|payloadType'"

# Check 3: Verification policy exists
check "Verification policy file exists" \
    "test -f /app/policy.yaml || test -f /app/policy.yml || test -f /app/admission-policy.yaml"

# Check 4: Unsigned image is rejected by policy
check "Unsigned image fails verification" \
    "! cosign verify --allow-http-registry --allow-insecure-registry --key /app/cosign.pub registry:5000/weaklink-app:unsigned 2>/dev/null"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

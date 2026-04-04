#!/bin/bash
#
# Verification script for Lab 4.6: Attestation Forgery
# Checks that the user forged an attestation and then defended with keyless signing.
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
echo "  Verifying Lab 4.6: Attestation Forgery"
echo "  ========================================"
echo ""

# Check 1: Forged attestation was created
check "Forged attestation file exists" \
    "test -f /app/forged-attestation.json && grep -q 'predicateType' /app/forged-attestation.json"

# Check 2: Forged attestation claims trusted CI as builder
check "Forged attestation claims trusted CI builder identity" \
    "grep -q 'github.com\|ci-builder\|trusted' /app/forged-attestation.json"

# Check 3: User demonstrated forgery passes basic signature check
check "Forgery verification documented (attack-log.md)" \
    "test -f /app/attack-log.md && grep -qi 'verified\|pass\|forgery\|succeeded' /app/attack-log.md"

# Check 4: Defense policy requires OIDC identity (not just any key)
check "Defense policy checks builder identity (OIDC issuer or certificate identity)" \
    "test -f /app/keyless-policy.yaml && grep -qi 'issuer\|identity\|oidc\|certificate' /app/keyless-policy.yaml"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

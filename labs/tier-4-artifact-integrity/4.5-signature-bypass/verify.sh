#!/bin/bash
#
# Verification script for Lab 4.5: Signature Bypass Attacks
# Checks that the user demonstrated bypasses and then hardened verification.
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
echo "  Verifying Lab 4.5: Signature Bypass Attacks"
echo "  ============================================="
echo ""

# Check 1: Attacker key pair was generated
check "Attacker key pair exists" \
    "test -f /app/attacker-cosign.key && test -f /app/attacker-cosign.pub"

# Check 2: Enforcement policy pins specific trusted key
check "Enforcement policy pins the trusted public key" \
    "test -f /app/enforce-policy.yaml && grep -q 'cosign.pub\|trusted' /app/enforce-policy.yaml"

# Check 3: Attacker-signed image is rejected
check "Attacker-signed image fails trusted key verification" \
    "! cosign verify --allow-http-registry --allow-insecure-registry --key /app/cosign.pub registry:5000/weaklink-app:attacker-signed 2>/dev/null"

# Check 4: Rollback attack documented
check "Rollback attack is documented" \
    "test -f /app/bypass-report.md && grep -qi 'rollback\|replay\|old.*signature' /app/bypass-report.md"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

#!/bin/bash
#
# Verification script for Lab 6.4: Multi-Vector Chained Attack
# Checks that the user has implemented defense-in-depth against chained attacks.
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
echo "  Verifying Lab 6.4: Multi-Vector Chained Attack"
echo "  ==============================================="
echo ""

# Check 1: No stage-1 compromise (typosquatting)
check "No stage-1 compromise marker (/tmp/stage1-typosquat does not exist)" \
    "test ! -f /tmp/stage1-typosquat"

# Check 2: No stage-2 compromise (CI poisoning)
check "No stage-2 compromise marker (/tmp/stage2-ci-poison does not exist)" \
    "test ! -f /tmp/stage2-ci-poison"

# Check 3: No stage-3 compromise (backdoored image)
check "No stage-3 compromise marker (/tmp/stage3-image-backdoor does not exist)" \
    "test ! -f /tmp/stage3-image-backdoor"

# Check 4: Package lockfile has integrity hashes
check "Package lockfile contains integrity hashes" \
    "grep -q 'integrity\|sha512\|sha256' /app/package-lock.json 2>/dev/null || grep -q 'hash\|sha256' /app/requirements.txt 2>/dev/null"

# Check 5: CI config is on a protected path
check "CI configuration is protected (CODEOWNERS or branch protection)" \
    "test -f /app/.github/CODEOWNERS && grep -q 'workflows' /app/.github/CODEOWNERS"

# Check 6: Container image verification is in place
check "Container image signature verification is configured" \
    "test -f /app/verify_image.sh && grep -q 'cosign\|notation\|digest' /app/verify_image.sh"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

#!/bin/bash
#
# Verification script for Lab 3.5: Layer Injection
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user can detect injected layers and has applied signing.
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
echo "  Verifying Lab 3.5: Layer Injection"
echo "  ===================================="
echo ""

# Check 1: User identified the injected layer
check "Injected layer identified in /app/findings.txt" \
    "test -f /app/findings.txt && grep -qi 'inject\|extra layer\|added layer\|reverse.shell\|backdoor' /app/findings.txt"

# Check 2: User compared layer counts (expected vs actual)
check "Layer count comparison documented" \
    "grep -qE '[0-9]+ layer' /app/findings.txt"

# Check 3: User extracted the injected layer content
check "Injected layer content extracted to /app/extracted-layers/" \
    "test -d /app/extracted-layers && find /app/extracted-layers -type f | head -1 | grep -q '.'"

# Check 4: Clean image signed with cosign (signature exists in registry)
check "Clean image signed (cosign signature or signing record exists)" \
    "test -f /app/cosign-output.txt && grep -qi 'signing\|Pushing signature\|tlog entry' /app/cosign-output.txt"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

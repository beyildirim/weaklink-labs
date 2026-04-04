#!/bin/bash
#
# Verification script for Lab 6.7: Case Study - Codecov Bash Uploader
# Checks understanding and defensive measures.
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
echo "  Verifying Lab 6.7: Case Study - Codecov"
echo "  ========================================"
echo ""

# Check 1: CI config does not use curl|bash pattern
check "CI config does not pipe external scripts into bash" \
    "! grep -rq 'curl.*|.*bash\|curl.*|.*sh\|wget.*|.*bash' /app/.github/workflows/"

# Check 2: Script integrity verification is in place
check "Script integrity verification checks SHA-256 before execution" \
    "test -f /app/verify_script.sh && grep -q 'sha256\|checksum\|hash' /app/verify_script.sh"

# Check 3: CI uses pinned action instead of bash script
check "CI uses official Codecov action (pinned by SHA) instead of bash script" \
    "grep -q 'codecov/codecov-action@' /app/.github/workflows/ci-fixed.yml"

# Check 4: Analysis covers the attack mechanism
check "Analysis covers Codecov exfiltration mechanism" \
    "test -f /app/analysis.md && grep -qi 'exfiltrat\|environment.*variable\|curl.*bash\|codecov' /app/analysis.md"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

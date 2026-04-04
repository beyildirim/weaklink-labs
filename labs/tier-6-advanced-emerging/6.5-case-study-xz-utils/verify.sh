#!/bin/bash
#
# Verification script for Lab 6.5: Case Study - xz-utils (CVE-2024-3094)
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
echo "  Verifying Lab 6.5: Case Study - xz-utils"
echo "  =========================================="
echo ""

# Check 1: Backdoor detection script identifies the malicious test file
check "Backdoor detection script identifies obfuscated test files" \
    "test -f /app/detect_xz_backdoor.sh && bash /app/detect_xz_backdoor.sh /app/xz-src 2>&1 | grep -qi 'suspicious\|backdoor\|detected'"

# Check 2: Build reproducibility check script exists
check "Build reproducibility verification script exists" \
    "test -f /app/check_reproducible.sh && grep -q 'diff\|sha256\|compare' /app/check_reproducible.sh"

# Check 3: Analysis document covers the key attack stages
check "Analysis covers social engineering timeline" \
    "test -f /app/analysis.md && grep -qi 'jia.*tan\|social.engineer\|maintainer.*burnout' /app/analysis.md"

# Check 4: Analysis covers the build system injection mechanism
check "Analysis covers build system injection via M4 macros" \
    "test -f /app/analysis.md && grep -qi 'm4\|build.*script\|configure\|ifunc\|liblzma' /app/analysis.md"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

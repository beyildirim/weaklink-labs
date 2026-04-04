#!/bin/bash
#
# Verification script for Lab 6.6: Case Study - SolarWinds (SUNBURST)
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
echo "  Verifying Lab 6.6: Case Study - SolarWinds"
echo "  ============================================"
echo ""

# Check 1: Build tampering detection identifies injected code
check "Build tampering detection script identifies DLL injection" \
    "test -f /app/detect_build_tampering.sh && bash /app/detect_build_tampering.sh /app/build-output 2>&1 | grep -qi 'tamper\|inject\|mismatch\|suspicious'"

# Check 2: Reproducible build verification exists
check "Reproducible build comparison script exists" \
    "test -f /app/verify_build.sh && grep -q 'diff\|sha256\|reproducible\|compare' /app/verify_build.sh"

# Check 3: Analysis covers the Sunburst attack mechanism
check "Analysis covers Sunburst DLL injection mechanism" \
    "test -f /app/analysis.md && grep -qi 'SolarWinds.Orion.Core.BusinessLayer\|sunburst\|dll' /app/analysis.md"

# Check 4: Analysis covers build system isolation recommendations
check "Analysis covers build system isolation and SLSA" \
    "test -f /app/analysis.md && grep -qi 'isol\|slsa\|hermetic\|reproducible' /app/analysis.md"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

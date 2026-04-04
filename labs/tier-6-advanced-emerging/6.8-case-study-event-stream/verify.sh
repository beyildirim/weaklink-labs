#!/bin/bash
#
# Verification script for Lab 6.8: Case Study - event-stream / ua-parser-js
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
echo "  Verifying Lab 6.8: Case Study - event-stream / ua-parser-js"
echo "  ============================================================"
echo ""

# Check 1: Package lockfile exists with integrity hashes
check "Package lockfile exists and contains integrity hashes" \
    "test -f /app/package-lock.json && grep -q 'integrity' /app/package-lock.json"

# Check 2: Maintainer monitoring script exists
check "Maintainer change monitoring script exists" \
    "test -f /app/monitor_maintainers.sh && grep -q 'npm\|maintainer\|owner' /app/monitor_maintainers.sh"

# Check 3: npm audit is configured to run
check "npm audit check is configured in CI" \
    "grep -rq 'npm audit\|audit-ci\|better-npm-audit' /app/.github/workflows/ 2>/dev/null || grep -q 'npm audit' /app/check_deps.sh 2>/dev/null"

# Check 4: Analysis covers both incidents
check "Analysis covers both event-stream and ua-parser-js incidents" \
    "test -f /app/analysis.md && grep -qi 'event-stream' /app/analysis.md && grep -qi 'ua-parser' /app/analysis.md"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

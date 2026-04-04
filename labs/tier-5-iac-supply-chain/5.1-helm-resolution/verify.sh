#!/bin/bash
#
# Verification script for Lab 5.1: How Helm Charts Resolve Dependencies
# Checks that the user has pinned chart dependencies and removed untrusted repos.
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
echo "  Verifying Lab 5.1: How Helm Charts Resolve Dependencies"
echo "  ========================================================"
echo ""

# Check 1: Chart.yaml pins exact versions (no ranges like ^, ~, >=)
check "Chart.yaml dependencies use exact version pins (no ranges)" \
    "grep -E 'version:' /app/webapp/Chart.yaml | grep -v -E '[\^~>]'"

# Check 2: Chart.lock exists with digests
check "Chart.lock exists with integrity digests" \
    "test -f /app/webapp/Chart.lock && grep -q 'digest:' /app/webapp/Chart.lock"

# Check 3: Untrusted public repo is removed from helm repo list
check "Untrusted public Helm repo is not configured" \
    "! helm repo list 2>/dev/null | grep -q 'untrusted-public'"

# Check 4: Private repo is configured
check "Private Helm repo is configured" \
    "helm repo list 2>/dev/null | grep -q 'private-charts'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

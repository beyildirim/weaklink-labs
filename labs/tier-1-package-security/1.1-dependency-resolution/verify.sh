#!/bin/bash
#
# Verification script for Lab 1.1: How Dependency Resolution Works
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user has properly defended against resolution issues.
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
echo "  Verifying Lab 1.1: How Dependency Resolution Works"
echo "  ==================================================="
echo ""

# Check 1: pip.conf uses --index-url (not --extra-index-url)
check "pip.conf uses --index-url (not --extra-index-url)" \
    "grep -q 'index-url' /etc/pip.conf && ! grep -q 'extra-index-url' /etc/pip.conf"

# Check 2: pip.conf points to private registry only
check "pip.conf points to private registry" \
    "grep -q 'private-pypi' /etc/pip.conf"

# Check 3: A lockfile (requirements.lock or frozen requirements) exists
check "Lockfile exists (requirements.lock or frozen output)" \
    "test -f /app/requirements.lock || test -f /app/requirements.frozen.txt"

# Check 4: internal-utils 1.0.0 is installed (not 99.0.0)
check "internal-utils==1.0.0 is installed (correct version)" \
    "pip show internal-utils 2>/dev/null | grep -q 'Version: 1.0.0'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

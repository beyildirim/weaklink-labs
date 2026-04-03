#!/bin/bash
#
# Verification script for Lab 1.2: Dependency Confusion
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user has defended against the dependency confusion attack.
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
echo "  Verifying Lab 1.2: Dependency Confusion"
echo "  ========================================"
echo ""

# Check 1: /tmp/dependency-confusion-pwned does NOT exist
check "No compromise marker (/tmp/dependency-confusion-pwned does not exist)" \
    "test ! -f /tmp/dependency-confusion-pwned"

# Check 2: pip config uses --index-url, NOT --extra-index-url
check "pip.conf uses --index-url (not --extra-index-url)" \
    "grep -q 'index-url' /etc/pip.conf && ! grep -q 'extra-index-url' /etc/pip.conf"

# Check 3: acme-auth==1.0.0 is installed (not 99.0.0)
check "acme-auth==1.0.0 is installed (legitimate version)" \
    "pip show acme-auth 2>/dev/null | grep -q 'Version: 1.0.0'"

# Check 4: pip config points to private registry
check "pip.conf points to private registry only" \
    "grep -q 'private-pypi' /etc/pip.conf && ! grep -q 'public-pypi' /etc/pip.conf"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

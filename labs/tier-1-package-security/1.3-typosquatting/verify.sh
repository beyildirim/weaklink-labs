#!/bin/bash
#
# Verification script for Lab 1.3: Typosquatting
# Runs INSIDE the workstation pod via kubectl exec.
#

set -uo pipefail

PASS=0
FAIL=0

check() {
    local description="$1"
    local result="$2"

    if [[ "$result" == "0" ]]; then
        echo "  [PASS] $description"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $description"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "  Verifying Lab 1.3: Typosquatting"
echo "  ================================="
echo ""

# Check 1: reqeusts (typosquatted) is NOT installed
pip show reqeusts > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    check "Typosquatted 'reqeusts' package is NOT installed" "0"
else
    check "Typosquatted 'reqeusts' package is NOT installed" "1"
fi

# Check 2: requests (legitimate) IS installed
pip show requests > /dev/null 2>&1
check "Legitimate 'requests' package IS installed" "$?"

# Check 3: /tmp/typosquat-exfil does NOT exist
test -f /tmp/typosquat-exfil 2>/dev/null
if [[ $? -ne 0 ]]; then
    check "Exfiltration file /tmp/typosquat-exfil does NOT exist" "0"
else
    check "Exfiltration file /tmp/typosquat-exfil does NOT exist" "1"
fi

# Check 4: A requirements.txt with pinned versions exists in /app/
test -f /app/requirements.txt 2>/dev/null
if [[ $? -eq 0 ]]; then
    # Check it contains exact version pins (== format)
    grep -q "==" /app/requirements.txt 2>/dev/null
    check "requirements.txt exists with pinned versions (==)" "$?"
else
    check "requirements.txt exists with pinned versions (==)" "1"
fi

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

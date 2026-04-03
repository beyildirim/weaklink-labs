#!/bin/bash
# Verification script for Lab 0.2: How Package Managers Work
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the student has:
#   1. /tmp/pwned does NOT exist (defense succeeded)
#   2. A requirements file with hashes exists
#   3. safe-utils is installed (via hash-verified install)

set -uo pipefail

PASS=0
FAIL=0

check() {
    local description="$1"
    local result="$2"
    if [ "$result" -eq 0 ]; then
        echo "  PASS: ${description}"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: ${description}"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "=== Lab 0.2 Verification: How Package Managers Work ==="
echo ""

# Check 1: PyPI server is running (K8s service DNS)
echo "[*] Checking PyPI server..."
if curl -sf "http://pypi-private:8080/simple/" > /dev/null 2>&1; then
    check "Local PyPI server is running" 0
else
    check "Local PyPI server is running" 1
fi

# Check 2: /tmp/pwned does NOT exist (the defense worked)
echo "[*] Checking that /tmp/pwned does not exist (malicious code was blocked)..."
if [ ! -f /tmp/pwned ]; then
    check "/tmp/pwned does not exist (malicious setup.py did not execute)" 0
else
    check "/tmp/pwned does not exist (malicious setup.py did not execute)" 1
fi

# Check 3: A requirements file with hashes exists
echo "[*] Checking for requirements file with hash pinning..."
HAS_HASHES=$(grep -c '\-\-hash=' /workspace/requirements.txt 2>/dev/null || echo 0)
if [ "${HAS_HASHES}" -gt 0 ] 2>/dev/null; then
    check "Requirements file with --hash= entries exists" 0
else
    check "Requirements file with --hash= entries exists" 1
fi

# Check 4: safe-utils is installed
echo "[*] Checking that safe-utils is installed..."
if pip show safe-utils > /dev/null 2>&1; then
    check "safe-utils package is installed" 0
else
    check "safe-utils package is installed" 1
fi

# Check 5: malicious-utils is NOT installed
echo "[*] Checking that malicious-utils is not installed..."
if ! pip show malicious-utils > /dev/null 2>&1; then
    check "malicious-utils package is not installed" 0
else
    check "malicious-utils package is not installed" 1
fi

# Summary
echo ""
echo "=== Results ==="
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"
echo ""

if [ "${FAIL}" -eq 0 ]; then
    echo "  ALL CHECKS PASSED -- Lab 0.2 complete!"
    echo ""
    exit 0
else
    echo "  Some checks failed. Review the steps in README.md and try again."
    echo ""
    exit 1
fi

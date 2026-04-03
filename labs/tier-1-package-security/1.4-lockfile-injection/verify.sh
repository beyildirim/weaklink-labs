#!/bin/bash
#
# Verification script for Lab 1.4: Lockfile Injection
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
echo "  Verifying Lab 1.4: Lockfile Injection"
echo "  ======================================="
echo ""

# Check 1: /tmp/lockfile-pwned does NOT exist
test -f /tmp/lockfile-pwned 2>/dev/null
if [[ $? -ne 0 ]]; then
    check "Compromise marker /tmp/lockfile-pwned does NOT exist" "0"
else
    check "Compromise marker /tmp/lockfile-pwned does NOT exist" "1"
fi

# Check 2: verify-lockfile.sh exists in the project
test -f /app/project/verify-lockfile.sh 2>/dev/null
check "verify-lockfile.sh script exists" "$?"

# Check 3: verify-lockfile.sh is executable
test -x /app/project/verify-lockfile.sh 2>/dev/null
check "verify-lockfile.sh is executable" "$?"

# Check 4: The lockfile matches a fresh pip-compile output
bash -c '
cd /app/project && \
pip-compile --generate-hashes \
    --index-url http://pypi:8080/simple/ \
    --trusted-host pypi \
    --quiet \
    requirements.in \
    --output-file /tmp/fresh-lockfile.txt 2>/dev/null && \
diff <(grep -v "^#" requirements.txt | grep -v "^$") \
     <(grep -v "^#" /tmp/fresh-lockfile.txt | grep -v "^$") > /dev/null 2>&1
' 2>/dev/null
check "Lockfile matches fresh pip-compile output (not tampered)" "$?"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

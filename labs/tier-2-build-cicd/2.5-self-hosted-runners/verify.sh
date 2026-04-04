#!/bin/bash
#
# Verification script for Lab 2.5: Self-Hosted Runner Attacks
# Checks that the runner environment is defended against persistence attacks.
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
echo "  Verifying Lab 2.5: Self-Hosted Runner Attacks"
echo "  =============================================="
echo ""

# Check 1: No backdoor marker
check "No runner compromise marker exists" \
    "test ! -f /tmp/runner-compromised"

# Check 2: Runner .bashrc is clean (no injected commands)
check "Runner .bashrc has no injected commands" \
    "! grep -qE '(curl|wget|nc|/tmp/|exfil|backdoor)' /runner/workspace/.bashrc"

# Check 3: Pre-job cleanup hook exists
check "Pre-job cleanup hook is installed" \
    "test -x /runner/hooks/pre-job.sh"

# Check 4: Cleanup hook removes temp files
check "Cleanup hook removes temp files" \
    "grep -q 'rm.*runner-compromised' /runner/hooks/pre-job.sh"

# Check 5: CI uses container isolation or ephemeral config
check "CI config uses container isolation" \
    "grep -q 'container:' /repos/acme-webapp/.gitea/workflows/ci.yml"

# Check 6: CI has clean state verification step
check "CI verifies clean state before build" \
    "grep -q 'clean state\|Verify.*clean\|verify.*state' /repos/acme-webapp/.gitea/workflows/ci.yml"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

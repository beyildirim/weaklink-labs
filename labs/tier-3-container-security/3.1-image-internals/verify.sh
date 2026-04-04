#!/bin/bash
#
# Verification script for Lab 3.1: Container Image Internals
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user understands image layers and can detect hidden content.
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
echo "  Verifying Lab 3.1: Container Image Internals"
echo "  =============================================="
echo ""

# Check 1: User has identified the hidden backdoor file name
check "Backdoor filename recorded in /app/findings.txt" \
    "test -f /app/findings.txt && grep -qi 'backdoor\|malicious\|reverse.shell\|implant' /app/findings.txt"

# Check 2: User ran docker history --no-trunc on the suspicious image
check "docker history output saved to /app/history-output.txt" \
    "test -f /app/history-output.txt && grep -qi 'COPY\|ADD\|RUN' /app/history-output.txt"

# Check 3: User identified which layer contains the hidden content
check "Hidden layer identified in /app/findings.txt (layer hash or number)" \
    "grep -qE 'sha256:|layer' /app/findings.txt"

# Check 4: User extracted and inspected individual layers
check "Layer extraction evidence exists (/app/extracted-layers/ directory)" \
    "test -d /app/extracted-layers && ls /app/extracted-layers/ | head -1 | grep -q '.'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

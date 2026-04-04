#!/bin/bash
#
# Verification script for Lab 3.3: Base Image Poisoning
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user has pinned the base image by digest and understands the risk.
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
echo "  Verifying Lab 3.3: Base Image Poisoning"
echo "  ========================================="
echo ""

# Check 1: Dockerfile pins base image by digest
check "Dockerfile FROM uses digest (@sha256:) instead of tag" \
    "grep -E '^FROM .+@sha256:' /app/Dockerfile"

# Check 2: User identified the backdoor in the poisoned base
check "Backdoor finding documented in /app/findings.txt" \
    "test -f /app/findings.txt && grep -qi 'backdoor\|malicious\|poisoned\|compromised' /app/findings.txt"

# Check 3: The app image was rebuilt with the clean base
check "App image rebuilt with safe base (no backdoor present)" \
    "docker run --rm registry:5000/myapp:secure cat /usr/local/bin/backdoor 2>/dev/null; test \$? -ne 0"

# Check 4: Scan results saved
check "Image scan output saved to /app/scan-results.txt" \
    "test -f /app/scan-results.txt && test -s /app/scan-results.txt"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

#!/bin/bash
#
# Verification script for Lab 3.2: Tag Mutability Attacks
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user has pinned images by digest and understands tag mutability.
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
echo "  Verifying Lab 3.2: Tag Mutability Attacks"
echo "  ==========================================="
echo ""

# Check 1: Deployment manifest uses digest reference (not tag-only)
check "Deployment uses image digest (@sha256:) instead of tag" \
    "grep -q '@sha256:' /app/deploy/deployment.yml"

# Check 2: No tag-only references remain in the deployment
check "No tag-only image references in deployment" \
    "! grep -E 'image:.*:[a-zA-Z0-9._-]+$' /app/deploy/deployment.yml | grep -v '@sha256:'"

# Check 3: User recorded the original and swapped digests
check "Digest comparison saved to /app/findings.txt" \
    "test -f /app/findings.txt && grep -cE 'sha256:' /app/findings.txt | grep -q '[2-9]'"

# Check 4: The safe image digest is pinned (not the backdoored one)
check "Pinned digest matches the safe image (not the backdoored image)" \
    "grep '@sha256:' /app/deploy/deployment.yml | grep -qf /app/safe-digest.txt"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

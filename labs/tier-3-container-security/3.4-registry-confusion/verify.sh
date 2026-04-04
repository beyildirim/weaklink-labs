#!/bin/bash
#
# Verification script for Lab 3.4: Registry Confusion
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user uses fully qualified image names and has blocked unapproved registries.
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
echo "  Verifying Lab 3.4: Registry Confusion"
echo "  ======================================="
echo ""

# Check 1: Deployment uses fully qualified image name (registry/repo:tag or @sha256)
check "Deployment uses fully qualified image name (includes registry host)" \
    "grep -E 'image: *registry:5000/' /app/deploy/deployment.yml"

# Check 2: No short image names (no docker.io implicit prefix)
check "No unqualified image names in deployment" \
    "! grep -E 'image: *[a-z]+:' /app/deploy/deployment.yml | grep -v 'registry:5000'"

# Check 3: Docker daemon config restricts allowed registries
check "Docker daemon or policy restricts registry sources" \
    "test -f /app/policy/registry-allowlist.yml && grep -q 'registry:5000' /app/policy/registry-allowlist.yml"

# Check 4: User documented the confusion attack in findings
check "Registry confusion attack documented in /app/findings.txt" \
    "test -f /app/findings.txt && grep -qi 'confusion\|priority\|override\|wrong registry' /app/findings.txt"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

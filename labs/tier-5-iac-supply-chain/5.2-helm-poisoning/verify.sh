#!/bin/bash
#
# Verification script for Lab 5.2: Helm Chart Poisoning
# Checks that the user has identified and removed the malicious hook
# and applied policy-based defenses.
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
echo "  Verifying Lab 5.2: Helm Chart Poisoning"
echo "  ========================================="
echo ""

# Check 1: Malicious post-install hook has been removed or neutralized
check "Malicious post-install hook removed from chart" \
    "! grep -r 'cluster-admin' /app/metrics-aggregator/templates/"

# Check 2: No ClusterRoleBinding granting cluster-admin to default SA
check "No ClusterRoleBinding granting cluster-admin to default SA" \
    "! helm template /app/metrics-aggregator/ 2>/dev/null | grep -A5 'ClusterRoleBinding' | grep -q 'cluster-admin'"

# Check 3: Kyverno/OPA policy file exists for hook validation
check "Hook validation policy exists" \
    "test -f /app/policies/restrict-hooks.yaml || test -f /app/policies/restrict-clusterrolebinding.yaml"

# Check 4: helm template output reviewed (marker file created by user)
check "User has reviewed rendered manifests (review marker exists)" \
    "test -f /app/.helm-reviewed"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

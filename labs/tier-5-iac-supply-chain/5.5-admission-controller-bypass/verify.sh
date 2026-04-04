#!/bin/bash
#
# Verification script for Lab 5.5: Kubernetes Admission Controller Bypass
# Checks that the user has closed the three bypass vectors.
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
echo "  Verifying Lab 5.5: Kubernetes Admission Controller Bypass"
echo "  ==========================================================="
echo ""

# Check 1: No exempt namespaces in Gatekeeper config (except kube-system)
check "No unnecessary namespace exemptions in Gatekeeper config" \
    "! grep -r 'exemptNamespaces' /app/gatekeeper-config/ | grep -v 'kube-system' | grep -q '.'"

# Check 2: CRD policy exists to cover custom resources
check "Policy covers custom resource definitions" \
    "test -f /app/policies/restrict-crds.yaml && grep -q 'CustomResourceDefinition' /app/policies/restrict-crds.yaml"

# Check 3: Audit mode policy exists for post-admission drift
check "Audit policy exists for detecting policy drift" \
    "test -f /app/policies/audit-config.yaml"

# Check 4: conftest tests exist for policy validation
check "Conftest test files exist for policy testing" \
    "test -f /app/policies/conftest/policy_test.rego || test -f /app/policies/conftest/test.rego"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

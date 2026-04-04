#!/bin/bash
#
# Verification script for Lab 2.1: CI/CD Fundamentals
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user has applied least-privilege secret scoping.
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
echo "  Verifying Lab 2.1: CI/CD Fundamentals"
echo "  ======================================"
echo ""

CI_FILE="/repos/acme-webapp/.gitea/workflows/ci.yml"

# Check 1: CI config exists
check "CI workflow file exists" \
    "test -f ${CI_FILE}"

# Check 2: No global-level secrets (no top-level env: with secrets)
check "No secrets in global env block" \
    "! awk '/^env:/,/^[a-z]/' ${CI_FILE} | grep -q 'secrets\.'"

# Check 3: Deploy job has scoped secrets
check "Deploy step has scoped DEPLOY_TOKEN" \
    "grep -A 30 'deploy:' ${CI_FILE} | grep -q 'DEPLOY_TOKEN'"

# Check 4: Test job does NOT have secrets
check "Test job does not reference secrets" \
    "! awk '/^  test:/,/^  [a-z]/' ${CI_FILE} | grep -q 'secrets\.'"

# Check 5: Build job does NOT have secrets
check "Build job does not reference secrets" \
    "! awk '/^  build:/,/^  [a-z]/' ${CI_FILE} | grep -q 'SECRET_TOKEN\|AWS_ACCESS_KEY'"

# Check 6: Environment protection on deploy
check "Deploy job uses environment protection" \
    "grep -A 5 'deploy:' ${CI_FILE} | grep -q 'environment:'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

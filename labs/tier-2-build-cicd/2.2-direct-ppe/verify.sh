#!/bin/bash
#
# Verification script for Lab 2.2: Direct Poisoned Pipeline Execution
# Checks that the user has defended against Direct PPE.
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
echo "  Verifying Lab 2.2: Direct PPE"
echo "  =============================="
echo ""

REPO="/repos/wl-webapp"

# Check 1: Main CI config only triggers on push (not PRs)
check "Main CI workflow does not trigger on pull_request" \
    "! grep -A 2 '^on:' ${REPO}/.gitea/workflows/ci.yml | grep -q 'pull_request'"

# Check 2: Separate PR workflow exists with no secrets
check "PR-specific workflow exists" \
    "test -f ${REPO}/.gitea/workflows/pr-ci.yml"

# Check 3: PR workflow does not reference secrets
check "PR workflow does not use secrets" \
    "! grep -q 'secrets\.' ${REPO}/.gitea/workflows/pr-ci.yml"

# Check 4: Main CI has scoped secrets (not global env)
check "Main CI has no global secret env block" \
    "! awk '/^env:/,/^[a-z]/' ${REPO}/.gitea/workflows/ci.yml | grep -q 'secrets\.'"

# Check 5: CODEOWNERS protects workflow directory
check "CODEOWNERS protects .gitea/workflows/" \
    "grep -q '.gitea/workflows/' ${REPO}/CODEOWNERS 2>/dev/null"

# Check 6: Deploy uses environment protection
check "Deploy job uses environment protection" \
    "grep -A 5 'deploy:' ${REPO}/.gitea/workflows/ci.yml | grep -q 'environment:'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

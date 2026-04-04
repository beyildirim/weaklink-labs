#!/bin/bash
#
# Verification script for Lab 2.4: Secret Exfiltration from CI
# Checks that secrets are properly protected.
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
echo "  Verifying Lab 2.4: Secret Exfiltration from CI"
echo "  ==============================================="
echo ""

REPO="/repos/acme-webapp"
CI="${REPO}/.gitea/workflows/ci.yml"

# Check 1: No global env secrets
check "No secrets in global env block" \
    "! awk '/^env:/,/^[a-z]/' ${CI} | grep -q 'secrets\.'"

# Check 2: No echo of secret values in any step
check "No echo of secret variables in CI steps" \
    "! grep -E 'echo.*\\\$(DB_PASSWORD|API_KEY|DEPLOY_TOKEN|SECRET)' ${CI}"

# Check 3: No secrets written to artifact files
check "No secrets written to build artifacts" \
    "! grep -E '(DB_PASSWORD|API_KEY|DEPLOY_TOKEN).*>' ${CI}"

# Check 4: PR workflow exists with no secrets
check "PR workflow exists without secrets" \
    "test -f ${REPO}/.gitea/workflows/pr-ci.yml && ! grep -q 'secrets\.' ${REPO}/.gitea/workflows/pr-ci.yml"

# Check 5: Secrets are scoped to deploy step only
check "Secrets scoped to deploy step only" \
    "grep -B 2 -A 5 'DEPLOY_TOKEN' ${CI} | grep -q 'deploy\|Deploy'"

# Check 6: Main CI does not trigger on PRs
check "Main CI does not trigger on pull_request" \
    "! grep -A 2 '^on:' ${CI} | grep -q 'pull_request'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

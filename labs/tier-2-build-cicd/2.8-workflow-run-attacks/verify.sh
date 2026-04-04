#!/bin/bash
#
# Verification script for Lab 2.8: Workflow Run & Cross-Workflow Attacks
# Checks that the deploy workflow validates artifact provenance.
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
echo "  Verifying Lab 2.8: Workflow Run & Cross-Workflow Attacks"
echo "  ======================================================="
echo ""

REPO="/repos/acme-webapp"
DEPLOY="${REPO}/.gitea/workflows/deploy.yml"

# Check 1: Deploy workflow exists
check "Deploy workflow exists" \
    "test -f ${DEPLOY}"

# Check 2: Deploy checks head_branch == main
check "Deploy validates triggering branch is main" \
    "grep -q 'head_branch.*main\|branches:.*main' ${DEPLOY}"

# Check 3: Deploy rejects PR-triggered workflows
check "Deploy rejects PR-triggered workflows" \
    "grep -q 'pull_request' ${DEPLOY} && grep -q 'exit 1\|Refusing' ${DEPLOY}"

# Check 4: Deploy does not execute downloaded scripts blindly
check "Deploy does not execute artifact scripts" \
    "! grep -q 'bash dist/deploy.sh' ${DEPLOY}"

# Check 5: Secrets are scoped (not global env)
check "Secrets are not in global env block" \
    "! awk '/^env:/,/^[a-z]/' ${DEPLOY} | grep -q 'secrets\.'"

# Check 6: Environment protection on deploy
check "Deploy job uses environment protection" \
    "grep -q 'environment:' ${DEPLOY}"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

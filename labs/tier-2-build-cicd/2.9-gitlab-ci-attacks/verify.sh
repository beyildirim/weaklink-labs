#!/bin/bash
#
# Verification script for Lab 2.9: GitLab CI Pipeline Attacks
# Checks that GitLab CI defenses are properly applied.
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
echo "  Verifying Lab 2.9: GitLab CI Pipeline Attacks"
echo "  ==============================================="
echo ""

REPO="/repos/acme-webapp"
CI_FILE="${REPO}/.gitlab-ci.yml"

# Check 1: Hardened CI file exists
check "Hardened .gitlab-ci.yml exists" \
    "test -f ${CI_FILE}"

# Check 2: No include:remote with external URLs
check "No include:remote with external URLs" \
    "! grep -A2 'include:' ${CI_FILE} | grep -q 'remote:.*http'"

# Check 3: Variables use protected flag or are restricted
check "CI variables are scoped to protected branches" \
    "grep -q 'protected\|only:.*protected\|rules:' ${CI_FILE}"

# Check 4: No unprotected trigger: blocks
check "Cross-project triggers use token authentication" \
    "! grep -B2 -A5 'trigger:' ${CI_FILE} | grep -q 'strategy: depend' || grep -q 'CI_JOB_TOKEN\|TRIGGER_TOKEN' ${CI_FILE}"

# Check 5: include: uses local or project-scoped references only
check "Includes are restricted to local or project-scoped references" \
    "! grep -A3 'include:' ${CI_FILE} | grep -qi 'remote:' || grep -A3 'include:' ${CI_FILE} | grep -qi 'project:'"

# Check 6: Merge request pipelines are restricted
check "Pipeline rules restrict merge request access to secrets" \
    "grep -q 'merge_request\|CI_MERGE_REQUEST\|if:.*merge' ${CI_FILE}"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

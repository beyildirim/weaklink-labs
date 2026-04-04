#!/bin/bash
#
# Verification script for Lab 2.6: GitHub Actions Injection
# Checks that expression injection vulnerabilities are fixed.
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
echo "  Verifying Lab 2.6: GitHub Actions Injection"
echo "  ============================================"
echo ""

REPO="/repos/acme-webapp"
ISSUE_WF="${REPO}/.gitea/workflows/issue-handler.yml"

# Check 1: No direct ${{ }} interpolation in run: blocks
check "No direct expression interpolation in run: blocks for issue title" \
    "! grep -E 'run:.*\\\$\\{\\{.*issue\\.title' ${ISSUE_WF} && ! grep -B 0 'echo.*\\\$\\{\\{.*issue\\.' ${ISSUE_WF}"

# Check 2: Issue title passed via env variable
check "Issue title passed through env variable" \
    "grep -q 'ISSUE_TITLE:.*github.event.issue.title' ${ISSUE_WF}"

# Check 3: Issue body passed via env variable (not direct interpolation)
check "Issue body passed through env variable" \
    "grep -q 'ISSUE_BODY:.*github.event.issue.body' ${ISSUE_WF}"

# Check 4: Shell uses ${VAR} not ${{ }} in run blocks
check "Run blocks use shell variables not expressions" \
    "grep -A 1 'run:' ${ISSUE_WF} | grep -q 'ISSUE_TITLE}\|ISSUE_BODY}\|ISSUE_AUTHOR}'"

# Check 5: PR handler is also fixed (if present)
if [ -f "${REPO}/.gitea/workflows/pr-handler.yml" ]; then
    check "PR handler does not use direct expression interpolation" \
        "! grep -E '\\\$\\{\\{.*comment\\.body' ${REPO}/.gitea/workflows/pr-handler.yml | grep -v '^[[:space:]]*#' | grep -q 'run:'"
fi

# Check 6: JSON payloads use jq for safe encoding
check "Slack notification uses safe JSON encoding" \
    "grep -q 'jq' ${ISSUE_WF}"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

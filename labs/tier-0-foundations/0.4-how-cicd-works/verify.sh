#!/bin/bash
# Verification script for Lab 0.4: How CI/CD Works
set -uo pipefail

GITEA_URL="http://gitea:3000"
ADMIN_USER="labadmin"
ADMIN_PASS="SupplyChainLab1!"
REPO="labadmin/ci-demo"

PASS=0
FAIL=0

check() {
    local description="$1"
    local result="$2"
    if [ "$result" -eq 0 ]; then
        echo "  PASS: ${description}"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: ${description}"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "=== Lab 0.4 Verification: How CI/CD Works ==="
echo ""

# Check 1: Gitea is running
if curl -sf "${GITEA_URL}/api/v1/version" > /dev/null 2>&1; then
    check "Gitea server is running" 0
else
    echo "  FAIL: Gitea not reachable"
    exit 1
fi

# Check 2: CI workflow file exists in repo
WORKFLOW=$(curl -sf "${GITEA_URL}/api/v1/repos/${REPO}/contents/.gitea/workflows/ci.yml" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$WORKFLOW" ]; then
    check "CI workflow file exists in repository" 0
else
    check "CI workflow file exists in repository" 1
fi

# Check 3: Branch protection on main (defense step)
PROTECTION=$(curl -sf "${GITEA_URL}/api/v1/repos/${REPO}/branch_protections" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" 2>/dev/null)
MAIN_PROTECTED=$(echo "${PROTECTION}" | grep -c '"main"' || true)
if [ "${MAIN_PROTECTED}" -gt 0 ]; then
    check "Branch protection enabled on main" 0
else
    check "Branch protection enabled on main" 1
fi

echo ""
echo "=== Results ==="
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"
echo ""
if [ "${FAIL}" -eq 0 ]; then
    echo "  ALL CHECKS PASSED -- Lab 0.4 complete!"
    exit 0
else
    echo "  Some checks failed."
    exit 1
fi

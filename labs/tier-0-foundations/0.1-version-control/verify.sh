#!/bin/bash
# Verification script for Lab 0.1: How Version Control Works
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the student has:
#   1. Branch protection enabled on main
#   2. A pull request exists (not a direct push)

set -uo pipefail

GITEA_URL="http://gitea:3000"
ADMIN_USER="weaklink"
ADMIN_PASS="weaklink"
REPO="weaklink/web-app"

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
echo "=== Lab 0.1 Verification: How Version Control Works ==="
echo ""

# Check 1: Gitea is running
echo "[*] Checking Gitea is accessible..."
if curl -sf "${GITEA_URL}/api/v1/version" > /dev/null 2>&1; then
    check "Gitea server is running" 0
else
    echo "  FAIL: Gitea server is not reachable at ${GITEA_URL}. Start the lab first: weaklink start 0.1"
    exit 1
fi

# Check 2: Branch protection is enabled on main
echo "[*] Checking branch protection on 'main'..."
PROTECTION=$(curl -sf "${GITEA_URL}/api/v1/repos/${REPO}/branch_protections" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" 2>/dev/null)

if [ $? -ne 0 ]; then
    check "Could retrieve branch protection rules" 1
else
    # Check if any rule covers 'main'
    MAIN_PROTECTED=$(echo "${PROTECTION}" | grep -c '"branch_name".*"main"' || true)
    if [ "${MAIN_PROTECTED}" -gt 0 ]; then
        check "Branch protection rule exists for 'main'" 0
    else
        # Also check rule_name field (Gitea uses different field names across versions)
        MAIN_PROTECTED2=$(echo "${PROTECTION}" | grep -c '"rule_name".*"main"' || true)
        if [ "${MAIN_PROTECTED2}" -gt 0 ]; then
            check "Branch protection rule exists for 'main'" 0
        else
            check "Branch protection rule exists for 'main'" 1
        fi
    fi

    # Check if push is disabled or reviews are required
    PUSH_DISABLED=$(echo "${PROTECTION}" | grep -c '"enable_push":false' || true)
    REVIEWS_REQUIRED=$(echo "${PROTECTION}" | grep -c '"required_approvals":[1-9]' || true)

    if [ "${PUSH_DISABLED}" -gt 0 ] || [ "${REVIEWS_REQUIRED}" -gt 0 ]; then
        check "Direct push is blocked or reviews are required" 0
    else
        check "Direct push is blocked or reviews are required" 1
    fi
fi

# Check 3: A pull request exists
echo "[*] Checking for pull requests..."
PRS=$(curl -sf "${GITEA_URL}/api/v1/repos/${REPO}/pulls?state=all" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" 2>/dev/null)

if [ $? -ne 0 ]; then
    check "Could retrieve pull requests" 1
else
    PR_COUNT=$(echo "${PRS}" | grep -c '"id":' || true)
    if [ "${PR_COUNT}" -gt 0 ]; then
        check "At least one pull request exists (not a direct push)" 0
    else
        check "At least one pull request exists (not a direct push)" 1
    fi
fi

# Check 4: The malicious build.sh line has been reverted
echo "[*] Checking that malicious code was reverted..."
MALICIOUS=$(cd /workspace/web-app && git pull -q 2>/dev/null; grep -c 'EXFILTRATED\|stolen-secrets' build.sh 2>/dev/null || echo 0)
if [ "${MALICIOUS}" -eq 0 ] 2>/dev/null; then
    check "Malicious code has been reverted from build.sh" 0
else
    check "Malicious code has been reverted from build.sh" 1
fi

# Summary
echo ""
echo "=== Results ==="
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"
echo ""

if [ "${FAIL}" -eq 0 ]; then
    echo "  ALL CHECKS PASSED. Lab 0.1 complete!"
    echo ""
    exit 0
else
    echo "  Some checks failed. Review the steps in README.md and try again."
    echo ""
    exit 1
fi

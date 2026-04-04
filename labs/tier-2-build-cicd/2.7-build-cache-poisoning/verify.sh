#!/bin/bash
#
# Verification script for Lab 2.7: Build Cache Poisoning
# Checks that the cache is properly secured.
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
echo "  Verifying Lab 2.7: Build Cache Poisoning"
echo "  ========================================="
echo ""

REPO="/repos/acme-webapp"
CI="${REPO}/.gitea/workflows/ci.yml"

# Check 1: No cache poison marker
check "No cache poisoning marker exists" \
    "test ! -f /tmp/cache-poisoned"

# Check 2: Cache key uses hashFiles (not static)
check "Cache key uses hashFiles for lockfile" \
    "grep -q 'hashFiles' ${CI}"

# Check 3: Cache key is not a static string
check "Cache key is not a static string" \
    "! grep -q 'key: pip-cache-v1' ${CI}"

# Check 4: PR builds have isolated cache (separate workflow or scoped key)
check "PR builds use isolated cache" \
    "test -f ${REPO}/.gitea/workflows/pr-ci.yml && grep -q 'pr-\|pull_request' ${REPO}/.gitea/workflows/pr-ci.yml"

# Check 5: Main CI does not run on PRs
check "Main CI does not trigger on pull_request" \
    "! grep -A 2 '^on:' ${CI} | grep -q 'pull_request'"

# Check 6: Dependency integrity verification exists
check "CI verifies dependency integrity" \
    "grep -qE '(pip-audit|pip freeze|sha256sum|hash)' ${CI}"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

#!/bin/bash
#
# Verification script for Lab 2.3: Indirect PPE
# Checks that CI-referenced files are integrity-verified.
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
echo "  Verifying Lab 2.3: Indirect PPE"
echo "  ================================"
echo ""

REPO="/repos/wl-webapp"

# Check 1: Checksum file exists
check "CI checksums file exists" \
    "test -f ${REPO}/.ci-checksums"

# Check 2: Checksum file covers Makefile
check "Checksums include Makefile" \
    "grep -q 'Makefile' ${REPO}/.ci-checksums"

# Check 3: Checksum file covers scripts
check "Checksums include scripts/run-tests.sh" \
    "grep -q 'scripts/run-tests.sh' ${REPO}/.ci-checksums"

# Check 4: CI config has integrity verification step
check "CI config verifies file integrity before execution" \
    "grep -q 'sha256sum' ${REPO}/.gitea/workflows/ci.yml"

# Check 5: Checksums are valid
check "Checksums match current files" \
    "cd ${REPO} && sha256sum -c .ci-checksums"

# Check 6: CI config does not run on PRs with secrets
check "Main CI does not give secrets to PR builds" \
    "! grep -A 2 '^on:' ${REPO}/.gitea/workflows/ci.yml | grep -q 'pull_request'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

#!/bin/bash
#
# Verification script for Lab 4.2: SBOM Gaps in Practice
# Checks that the user compared multiple SBOM generators and found coverage gaps.
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
echo "  Verifying Lab 4.2: SBOM Gaps in Practice"
echo "  ==========================================="
echo ""

# Check 1: Multiple SBOMs generated (at least 2 different tools)
check "SBOM from syft exists" \
    "test -f /app/sbom-syft.json && (grep -q 'spdxVersion\|bomFormat' /app/sbom-syft.json)"

check "SBOM from trivy exists" \
    "test -f /app/sbom-trivy.json && (grep -q 'spdxVersion\|bomFormat' /app/sbom-trivy.json)"

check "SBOM from cdxgen exists" \
    "test -f /app/sbom-cdxgen.json && (grep -q 'spdxVersion\|bomFormat' /app/sbom-cdxgen.json)"

# Check 2: Vulnerability scan was run
check "Vulnerability scan output exists (grype or trivy)" \
    "test -f /app/vuln-scan.txt || test -f /app/vuln-scan.json"

# Check 3: User documented the vendored CVE that SBOMs missed
check "Gap analysis documents the missed vendored CVE" \
    "test -f /app/gap-analysis.md && grep -qi 'CVE\|vendored\|missed\|gap' /app/gap-analysis.md"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

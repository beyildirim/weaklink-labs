#!/bin/bash
#
# Verification script for Lab 4.1: What SBOMs Actually Contain
# Checks that the user generated SBOMs and understands their limitations.
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
echo "  Verifying Lab 4.1: What SBOMs Actually Contain"
echo "  ================================================"
echo ""

# Check 1: SPDX SBOM was generated
check "SPDX format SBOM exists" \
    "test -f /app/sbom-spdx.json && grep -q 'spdxVersion' /app/sbom-spdx.json"

# Check 2: CycloneDX SBOM was generated
check "CycloneDX format SBOM exists" \
    "test -f /app/sbom-cdx.json && grep -q 'bomFormat' /app/sbom-cdx.json"

# Check 3: cdxgen SBOM was generated
check "cdxgen SBOM exists" \
    "test -f /app/sbom-cdxgen.json && grep -q 'bomFormat\|components' /app/sbom-cdxgen.json"

# Check 4: User created an enriched SBOM that includes vendored components
check "Enriched SBOM includes vendored component (libcurl)" \
    "test -f /app/sbom-enriched.json && grep -qi 'libcurl\|vendored\|manual' /app/sbom-enriched.json"

# Check 5: User documented SBOM gaps in a gaps file
check "SBOM gaps documented (gaps.txt or gaps.md exists)" \
    "test -f /app/gaps.txt || test -f /app/gaps.md"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

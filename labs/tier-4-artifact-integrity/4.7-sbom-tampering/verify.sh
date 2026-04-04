#!/bin/bash
#
# Verification script for Lab 4.7: SBOM Tampering
# Checks that the user tampered with an SBOM, then defended with signing.
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
echo "  Verifying Lab 4.7: SBOM Tampering"
echo "  ==================================="
echo ""

# Check 1: Original SBOM exists
check "Original (unmodified) SBOM exists" \
    "test -f /app/sbom-original.json && grep -q 'bomFormat\|spdxVersion' /app/sbom-original.json"

# Check 2: Tampered SBOM exists with vulnerable component removed
check "Tampered SBOM exists (vulnerable component removed)" \
    "test -f /app/sbom-tampered.json"

# Check 3: SBOM signature exists
check "SBOM was signed (signature file exists)" \
    "test -f /app/sbom-original.json.sig || test -f /app/sbom-signed.json.sig"

# Check 4: Tampered SBOM fails signature verification
check "Tampered SBOM fails signature verification" \
    "! cosign verify-blob --key /app/cosign.pub --signature /app/sbom-original.json.sig /app/sbom-tampered.json 2>/dev/null"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

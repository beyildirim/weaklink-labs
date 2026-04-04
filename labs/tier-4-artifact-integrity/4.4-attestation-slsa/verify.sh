#!/bin/bash
#
# Verification script for Lab 4.4: Attestation & Provenance (SLSA)
# Checks that the user created and verified build provenance attestations.
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
echo "  Verifying Lab 4.4: Attestation & Provenance (SLSA)"
echo "  ===================================================="
echo ""

# Check 1: Provenance attestation was created
check "Provenance attestation file exists" \
    "test -f /app/provenance.json && grep -q 'predicateType\|predicate' /app/provenance.json"

# Check 2: Attestation contains SLSA provenance predicate
check "Attestation uses SLSA provenance predicate type" \
    "grep -q 'slsa\|https://slsa.dev' /app/provenance.json"

# Check 3: Attestation was attached to the image
check "Image has an attached attestation" \
    "cosign verify-attestation --key /app/cosign.pub --type slsaprovenance registry:5000/weaklink-app:attested 2>/dev/null | grep -q 'payloadType\|predicateType'"

# Check 4: User identified the unattested image as unverifiable
check "Verification of unattested image fails" \
    "! cosign verify-attestation --key /app/cosign.pub --type slsaprovenance registry:5000/weaklink-app:no-provenance 2>/dev/null"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

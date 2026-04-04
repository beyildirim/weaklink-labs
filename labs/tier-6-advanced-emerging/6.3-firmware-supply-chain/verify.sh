#!/bin/bash
#
# Verification script for Lab 6.3: Firmware & Hardware Supply Chain
# Checks that the user has defended against firmware supply chain attacks.
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
echo "  Verifying Lab 6.3: Firmware & Hardware Supply Chain"
echo "  ==================================================="
echo ""

# Check 1: Firmware signature verification script exists
check "Firmware signature verification is implemented" \
    "test -f /app/verify_firmware.sh && grep -q 'openssl\|gpg\|cosign\|sha256' /app/verify_firmware.sh"

# Check 2: Tampered firmware is rejected by verification
check "Tampered firmware image fails signature verification" \
    "/app/verify_firmware.sh /app/firmware/tampered_update.bin 2>&1 | grep -qi 'fail\|invalid\|reject'"

# Check 3: Legitimate firmware passes verification
check "Legitimate firmware image passes signature verification" \
    "/app/verify_firmware.sh /app/firmware/legitimate_update.bin 2>&1 | grep -qi 'pass\|valid\|ok\|success'"

# Check 4: Firmware SBOM has been generated
check "Firmware SBOM exists in CycloneDX or SPDX format" \
    "find /app/firmware -name '*sbom*' -o -name '*spdx*' -o -name '*cyclonedx*' | grep -q '.'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

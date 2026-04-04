#!/bin/bash
#
# Verification script for Lab 8.2: SSDF / NIST SP 800-218 Mapping
# Checks that the user completed the SSDF mapping, roadmap, and attestation.
#

set -uo pipefail

PASS=0
FAIL=0
WORK_DIR="${WORK_DIR:-/app/deliverables}"

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
echo "  Verifying Lab 8.2: SSDF / NIST SP 800-218 Mapping"
echo "  ==================================================="
echo ""

# Check 1: Mapping worksheet exists
check "SSDF mapping worksheet exists" \
    "test -f ${WORK_DIR}/ssdf-mapping-worksheet.md"

# Check 2: Mapping has coverage entries filled in
check "Mapping worksheet has coverage assessments (Full/Partial/None)" \
    "grep -cE 'Full|Partial|None' ${WORK_DIR}/ssdf-mapping-worksheet.md 2>/dev/null | awk '{exit (\$1 >= 5 ? 0 : 1)}'"

# Check 3: Coverage summary has numbers
check "Coverage summary table has numeric values" \
    "grep -A6 'Coverage Summary' ${WORK_DIR}/ssdf-mapping-worksheet.md 2>/dev/null | grep -qE '\|.*[0-9]+.*\|'"

# Check 4: Compliance roadmap exists
check "SSDF compliance roadmap exists" \
    "test -f ${WORK_DIR}/ssdf-compliance-roadmap.md"

# Check 5: Roadmap has phased actions
check "Roadmap contains actions in at least two phases" \
    "grep -cE 'Phase [1-3]' ${WORK_DIR}/ssdf-compliance-roadmap.md 2>/dev/null | awk '{exit (\$1 >= 2 ? 0 : 1)}'"

# Check 6: Attestation form exists
check "SSDF attestation form exists" \
    "test -f ${WORK_DIR}/ssdf-attestation-form.md"

# Check 7: Attestation form has checkboxes marked
check "Attestation form has at least 3 items checked" \
    "grep -cE '\[x\]|\[X\]' ${WORK_DIR}/ssdf-attestation-form.md 2>/dev/null | awk '{exit (\$1 >= 3 ? 0 : 1)}'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

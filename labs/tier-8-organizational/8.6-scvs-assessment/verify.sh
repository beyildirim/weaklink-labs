#!/bin/bash
#
# Verification script for Lab 8.6: OWASP SCVS Framework Assessment
# Checks that the user completed the SCVS assessment deliverables.
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
echo "  Verifying Lab 8.6: OWASP SCVS Framework Assessment"
echo "  ===================================================="
echo ""

# Check 1: SCVS assessment worksheet exists
check "SCVS assessment worksheet exists" \
    "test -f ${WORK_DIR}/scvs-assessment.md"

# Check 2: Assessment covers all 6 SCVS categories
check "Assessment covers all 6 SCVS verification categories" \
    "grep -cE 'V1.*Inventory|V2.*Bill of Materials|V3.*Build Environment|V4.*Package Management|V5.*Component Analysis|V6.*Pedigree' ${WORK_DIR}/scvs-assessment.md 2>/dev/null | awk '{exit (\$1 >= 6 ? 0 : 1)}'"

# Check 3: At least one maturity level evaluated per category (controls marked)
check "At least 10 controls have been evaluated (Met/Partial/Not Met)" \
    "grep -cE 'Met|Not Met|Partial' ${WORK_DIR}/scvs-assessment.md 2>/dev/null | awk '{exit (\$1 >= 10 ? 0 : 1)}'"

# Check 4: Gap-to-lab mapping exists
check "Gap-to-lab mapping identifies WeakLink Labs for remediation" \
    "grep -cE 'Lab [0-9]+\.[0-9]+|Tier [0-9]' ${WORK_DIR}/scvs-assessment.md 2>/dev/null | awk '{exit (\$1 >= 3 ? 0 : 1)}'"

# Check 5: Compliance report exists
check "SCVS compliance report exists" \
    "test -f ${WORK_DIR}/scvs-compliance-report.md"

# Check 6: Compliance report has an overall maturity determination
check "Compliance report includes overall maturity level determination" \
    "grep -qE 'Overall.*Maturity|Current.*Level|Maturity.*Level' ${WORK_DIR}/scvs-compliance-report.md 2>/dev/null"

# Check 7: Compliance report contains remediation roadmap
check "Compliance report contains a remediation roadmap" \
    "grep -qiE 'roadmap|remediation plan|action plan' ${WORK_DIR}/scvs-compliance-report.md 2>/dev/null"

# Check 8: Overlap matrix exists
check "Framework overlap matrix exists" \
    "test -f ${WORK_DIR}/scvs-overlap-matrix.md"

# Check 9: Overlap matrix references SLSA and SSDF
check "Overlap matrix maps SCVS to both SLSA and SSDF" \
    "grep -qE 'SLSA' ${WORK_DIR}/scvs-overlap-matrix.md 2>/dev/null && grep -qE 'SSDF' ${WORK_DIR}/scvs-overlap-matrix.md 2>/dev/null"

# Check 10: Overlap matrix references EO 14028
check "Overlap matrix includes EO 14028 mapping" \
    "grep -qE 'EO.14028|Executive.Order' ${WORK_DIR}/scvs-overlap-matrix.md 2>/dev/null"

# Check 11: Actionable checklist exists in compliance report
check "Compliance report includes actionable checklists per SCVS category" \
    "grep -cE '\[ \]|\[x\]|\[X\]' ${WORK_DIR}/scvs-compliance-report.md 2>/dev/null | awk '{exit (\$1 >= 6 ? 0 : 1)}'"

# Check 12: Remediation items are prioritized
check "Remediation roadmap includes priority ranking" \
    "grep -qiE 'priority|high|medium|low|P[1-3]' ${WORK_DIR}/scvs-compliance-report.md 2>/dev/null"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

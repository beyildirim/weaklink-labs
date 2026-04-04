#!/bin/bash
#
# Verification script for Lab 8.4: Vendor Supply Chain Assessment
# Checks that the user completed the vendor questionnaire and risk report.
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
echo "  Verifying Lab 8.4: Vendor Supply Chain Assessment"
echo "  ==================================================="
echo ""

# Check 1: Completed questionnaire exists
check "Vendor questionnaire exists" \
    "test -f ${WORK_DIR}/vendor-questionnaire.md"

# Check 2: Questionnaire has scores filled in
check "Questionnaire has at least 10 questions scored (0-3)" \
    "grep -cE 'Score.*[0-3]|[0-3].*Evidence|^\|.*\| [0-3] \|' ${WORK_DIR}/vendor-questionnaire.md 2>/dev/null | awk '{exit (\$1 >= 5 ? 0 : 1)}'"

# Check 3: Overall scoring table has values
check "Overall scoring table has section scores filled in" \
    "grep -A10 'Overall Scoring' ${WORK_DIR}/vendor-questionnaire.md 2>/dev/null | grep -qE '\|.*[0-9]+.*\|.*[0-9]+.*\|'"

# Check 4: Risk rating is assigned
check "Vendor risk rating is assigned" \
    "grep -qiE 'Risk Rating.*:.*Low|Risk Rating.*:.*Moderate|Risk Rating.*:.*High|Risk Rating.*:.*Critical' ${WORK_DIR}/vendor-questionnaire.md 2>/dev/null"

# Check 5: Risk report exists
check "Vendor risk assessment report exists" \
    "test -f ${WORK_DIR}/vendor-risk-report.md"

# Check 6: Report has an executive summary
check "Risk report contains an executive summary with a recommendation" \
    "grep -qiE 'Approve|Reject|Conditional' ${WORK_DIR}/vendor-risk-report.md 2>/dev/null"

# Check 7: Report has findings
check "Risk report contains findings for at least 3 categories" \
    "grep -cE '### [0-9]+\.' ${WORK_DIR}/vendor-risk-report.md 2>/dev/null | awk '{exit (\$1 >= 3 ? 0 : 1)}'"

# Check 8: Report has recommendations
check "Risk report contains actionable recommendations" \
    "grep -A10 'Required Actions\|Recommended Improvements' ${WORK_DIR}/vendor-risk-report.md 2>/dev/null | grep -qE '\|.*[A-Za-z].*\|'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

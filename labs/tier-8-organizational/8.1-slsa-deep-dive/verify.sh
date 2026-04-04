#!/bin/bash
#
# Verification script for Lab 8.1: SLSA Framework Deep Dive
# Checks that the user completed the SLSA self-assessment deliverables.
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
echo "  Verifying Lab 8.1: SLSA Framework Deep Dive"
echo "  ============================================="
echo ""

# Check 1: Self-assessment file exists
check "SLSA self-assessment file exists" \
    "test -f ${WORK_DIR}/slsa-self-assessment.md"

# Check 2: Self-assessment has the current level filled in
check "Self-assessment includes a claimed SLSA level" \
    "grep -qE 'Claimed Level.*[0-4]' ${WORK_DIR}/slsa-self-assessment.md 2>/dev/null"

# Check 3: At least one level section is evaluated (not all blank)
check "At least one SLSA level has been evaluated (Yes/No marked)" \
    "grep -cE '\[x\]|\[X\]|Yes|No' ${WORK_DIR}/slsa-self-assessment.md 2>/dev/null | awk '{exit (\$1 >= 3 ? 0 : 1)}'"

# Check 4: Gap analysis section is filled in
check "Gap analysis summary contains identified gaps" \
    "grep -A5 'Top 3 Gaps' ${WORK_DIR}/slsa-self-assessment.md 2>/dev/null | grep -qE 'Gap:.*[A-Za-z]'"

# Check 5: Action plan has at least one item
check "Action plan contains at least one action item" \
    "grep -A10 'Action Plan to Reach' ${WORK_DIR}/slsa-self-assessment.md 2>/dev/null | grep -qE '\|.*[A-Za-z].*\|.*[A-Za-z].*\|'"

# Check 6: CI/CD changes section is filled in
check "CI/CD changes section includes specific changes" \
    "grep -A10 'Build Pipeline Changes' ${WORK_DIR}/slsa-self-assessment.md 2>/dev/null | grep -qE '\|.*[A-Za-z].*\|.*[A-Za-z].*\|'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

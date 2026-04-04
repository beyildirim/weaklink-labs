#!/bin/bash
#
# Verification script for Lab 8.5: Building a Supply Chain Security Program
# Checks that the user produced both the executive briefing and detailed plan.
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
echo "  Verifying Lab 8.5: Building a Supply Chain Security Program"
echo "  ============================================================"
echo ""

# Check 1: Executive briefing exists
check "Executive briefing exists" \
    "test -f ${WORK_DIR}/executive-briefing.md"

# Check 2: Briefing covers all six pillars
check "Executive briefing references all six program pillars" \
    "grep -ciE 'governance|tooling|training|monitoring|incident.response|continuous.improvement' ${WORK_DIR}/executive-briefing.md 2>/dev/null | awk '{exit (\$1 >= 6 ? 0 : 1)}'"

# Check 3: Briefing has timeline
check "Executive briefing includes a phased timeline" \
    "grep -cE '30.day|90.day|6.month|1.year' ${WORK_DIR}/executive-briefing.md 2>/dev/null | awk '{exit (\$1 >= 3 ? 0 : 1)}'"

# Check 4: Briefing has budget/investment section
check "Executive briefing includes investment or budget information" \
    "grep -qiE 'invest|budget|cost|funding' ${WORK_DIR}/executive-briefing.md 2>/dev/null"

# Check 5: Implementation plan exists
check "Detailed implementation plan exists" \
    "test -f ${WORK_DIR}/implementation-plan.md"

# Check 6: Plan covers all six pillars with actions
check "Implementation plan covers at least 5 pillars with specific actions" \
    "grep -cE '^## Pillar' ${WORK_DIR}/implementation-plan.md 2>/dev/null | awk '{exit (\$1 >= 5 ? 0 : 1)}'"

# Check 7: Plan has 4 time horizons
check "Implementation plan includes all 4 time horizons (30d, 90d, 6m, 1y)" \
    "grep -cE '30 Days|90 Days|6 Months|1 Year' ${WORK_DIR}/implementation-plan.md 2>/dev/null | awk '{exit (\$1 >= 4 ? 0 : 1)}'"

# Check 8: Plan has metrics
check "Implementation plan includes success metrics" \
    "grep -qiE 'metric|KPI|measure' ${WORK_DIR}/implementation-plan.md 2>/dev/null"

# Check 9: Maturity assessment exists
check "Program maturity assessment exists" \
    "test -f ${WORK_DIR}/program-maturity-model.md"

# Check 10: Maturity model has a current level assessed
check "Maturity model has a current level assessment" \
    "grep -qE 'Current.*Level.*[1-5]|Current Overall Maturity.*Level [1-5]' ${WORK_DIR}/program-maturity-model.md 2>/dev/null"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

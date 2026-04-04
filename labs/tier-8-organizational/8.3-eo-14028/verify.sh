#!/bin/bash
#
# Verification script for Lab 8.3: Executive Order 14028 Compliance
# Checks that the user completed the compliance checklist, SBOM, and VEX.
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
echo "  Verifying Lab 8.3: Executive Order 14028 Compliance"
echo "  ===================================================="
echo ""

# Check 1: Compliance checklist exists
check "EO 14028 compliance checklist exists" \
    "test -f ${WORK_DIR}/eo14028-compliance-checklist.md"

# Check 2: Checklist has items marked
check "Checklist has requirements marked as Met or Not Met" \
    "grep -cE 'Met|Not Met' ${WORK_DIR}/eo14028-compliance-checklist.md 2>/dev/null | awk '{exit (\$1 >= 5 ? 0 : 1)}'"

# Check 3: SBOM exists and is valid JSON
check "Sample SBOM file exists and is valid JSON" \
    "test -f ${WORK_DIR}/sample-sbom.json && python3 -m json.tool ${WORK_DIR}/sample-sbom.json > /dev/null 2>&1"

# Check 4: SBOM contains required fields
check "SBOM contains bomFormat and specVersion fields" \
    "grep -q 'bomFormat' ${WORK_DIR}/sample-sbom.json 2>/dev/null && grep -q 'specVersion' ${WORK_DIR}/sample-sbom.json 2>/dev/null"

# Check 5: SBOM has at least one real component (not just placeholder)
check "SBOM contains at least one component with a real name (not placeholder)" \
    "python3 -c \"
import json, sys
with open('${WORK_DIR}/sample-sbom.json') as f:
    data = json.load(f)
comps = data.get('components', [])
real = [c for c in comps if 'PLACEHOLDER' not in c.get('name', 'PLACEHOLDER')]
sys.exit(0 if len(real) >= 1 else 1)
\" 2>/dev/null"

# Check 6: VEX document exists and is valid JSON
check "VEX document exists and is valid JSON" \
    "test -f ${WORK_DIR}/sample-vex.json && python3 -m json.tool ${WORK_DIR}/sample-vex.json > /dev/null 2>&1"

# Check 7: VEX contains at least one statement with a real CVE or vulnerability
check "VEX contains at least one vulnerability statement" \
    "python3 -c \"
import json, sys
with open('${WORK_DIR}/sample-vex.json') as f:
    data = json.load(f)
stmts = data.get('statements', [])
real = [s for s in stmts if 'XXXXX' not in s.get('vulnerability', {}).get('name', 'XXXXX')]
sys.exit(0 if len(real) >= 1 else 1)
\" 2>/dev/null"

# Check 8: Remediation plan has entries
check "Compliance checklist includes a remediation plan with actions" \
    "grep -A10 'Remediation Plan' ${WORK_DIR}/eo14028-compliance-checklist.md 2>/dev/null | grep -qE '\|.*P[1-3].*\|.*[A-Za-z].*\|'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

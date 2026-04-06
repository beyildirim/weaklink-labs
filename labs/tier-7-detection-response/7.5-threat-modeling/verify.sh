#!/usr/bin/env bash
# Verify script for Lab 7.5: Threat Modeling for Software Supply Chains
# Checks that the learner built a threat model with STRIDE analysis and prioritized risk register.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=5

pass() { echo "  PASS: $1"; ((PASS++)) || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true; }

echo "=== Lab 7.5: Threat Modeling Verification ==="
echo ""

# Check 1: Supply chain map exists
if [ -f "$WORK_DIR/supply-chain-map.md" ] || [ -f "$WORK_DIR/supply-chain-map.txt" ] || [ -f "$WORK_DIR/supply-chain-map.png" ]; then
    pass "Supply chain map document exists"
else
    fail "No supply chain map found (expected supply-chain-map.md, .txt, or .png in $WORK_DIR)"
fi

# Check 2: Trust boundaries identified
BOUNDARY_REFS=$(grep -c -iE '(trust.boundar|boundary|transition|handoff|cross.?cut)' "$WORK_DIR"/supply-chain-map.* "$WORK_DIR"/threat-model.* 2>/dev/null || echo 0)
if [ "$BOUNDARY_REFS" -ge 3 ]; then
    pass "Trust boundaries identified ($BOUNDARY_REFS references)"
else
    fail "Insufficient trust boundary analysis (found $BOUNDARY_REFS references, need 3+)"
fi

# Check 3: STRIDE analysis performed
if [ -f "$WORK_DIR/threat-model.md" ] || [ -f "$WORK_DIR/threat-model.txt" ] || [ -f "$WORK_DIR/stride-analysis.md" ]; then
    STRIDE_COUNT=0
    for element in "spoof" "tamper" "repudiat" "disclosure\|information.leak" "denial.of.service\|dos" "elevation\|privilege.escalat"; do
        if grep -qi "$element" "$WORK_DIR"/threat-model.* "$WORK_DIR"/stride-analysis.* 2>/dev/null; then
            ((STRIDE_COUNT++)) || true
        fi
    done
    if [ "$STRIDE_COUNT" -ge 4 ]; then
        pass "STRIDE analysis covers $STRIDE_COUNT/6 threat categories (minimum 4)"
    else
        fail "STRIDE analysis only covers $STRIDE_COUNT/6 categories (need at least 4)"
    fi
else
    fail "No threat model or STRIDE analysis found (expected threat-model.md or stride-analysis.md in $WORK_DIR)"
fi

# Check 4: Risk prioritization with likelihood and impact
if grep -qiE '(likelihood|probability|impact|risk.score|risk.rating|high|medium|low|critical)' "$WORK_DIR"/threat-model.* "$WORK_DIR"/stride-analysis.* "$WORK_DIR"/risk-register.* 2>/dev/null; then
    pass "Risk prioritization with likelihood/impact assessment present"
else
    fail "No risk prioritization found -- must rank threats by likelihood and impact"
fi

# Check 5: Gap analysis mapping threats to controls
if [ -f "$WORK_DIR/gap-analysis.md" ] || [ -f "$WORK_DIR/gap-analysis.txt" ] || [ -f "$WORK_DIR/risk-register.md" ]; then
    CONTROL_REFS=$(grep -c -iE '(control|mitigation|countermeasure|defense|gap|residual|existing|missing)' "$WORK_DIR"/gap-analysis.* "$WORK_DIR"/risk-register.* 2>/dev/null || echo 0)
    if [ "$CONTROL_REFS" -ge 3 ]; then
        pass "Gap analysis maps threats to controls ($CONTROL_REFS references)"
    else
        fail "Gap analysis found but lacks control mapping (found $CONTROL_REFS references, need 3+)"
    fi
else
    fail "No gap analysis found (expected gap-analysis.md or risk-register.md in $WORK_DIR)"
fi

echo ""
echo "=== Results: $PASS/$TOTAL passed ==="

if [ "$PASS" -eq "$TOTAL" ]; then
    echo "Lab 7.5 COMPLETE"
    exit 0
else
    echo "Lab 7.5 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

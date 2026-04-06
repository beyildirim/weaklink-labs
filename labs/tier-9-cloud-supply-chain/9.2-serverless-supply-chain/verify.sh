#!/usr/bin/env bash
# Verify script for Lab 9.2: Serverless Supply Chain
# Checks that the learner analyzed malicious layers, identified dependency confusion, and documented defenses.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=6

pass() { echo "  PASS: $1"; ((PASS++)) || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true; }

echo "=== Lab 9.2: Serverless Supply Chain Verification ==="
echo ""

# Check 1: Malicious layer analysis exists
if [ -f "$WORK_DIR/layer-analysis.md" ] || [ -f "$WORK_DIR/layer-analysis.txt" ]; then
    LAYER_REFS=$(grep -c -iE '(layer|intercept|exfiltrat|event.data|wrapper|monkey.?patch|arn)' "$WORK_DIR"/layer-analysis.* 2>/dev/null || echo 0)
    if [ "$LAYER_REFS" -ge 3 ]; then
        pass "Layer analysis identifies interception mechanisms ($LAYER_REFS references)"
    else
        fail "Layer analysis found but lacks detail (found $LAYER_REFS references, need 3+)"
    fi
else
    fail "No layer analysis found (expected layer-analysis.md or .txt in $WORK_DIR)"
fi

# Check 2: Dependency confusion attack analysis
if [ -f "$WORK_DIR/depconfusion-analysis.md" ] || [ -f "$WORK_DIR/depconfusion-analysis.txt" ]; then
    pass "Dependency confusion analysis documented"
else
    # Also check if it's in a combined analysis file
    if grep -r -iE 'dependency.confusion' "$WORK_DIR"/*.* 2>/dev/null | grep -qi 'serverless\|lambda\|function'; then
        pass "Dependency confusion analysis found in combined document"
    else
        fail "No dependency confusion analysis found (expected depconfusion-analysis.md or .txt in $WORK_DIR)"
    fi
fi

# Check 3: Hardened function configuration exists
if [ -f "$WORK_DIR/hardened-function.json" ] || [ -f "$WORK_DIR/hardened-function.yml" ] || [ -f "$WORK_DIR/hardened-function.yaml" ] || [ -f "$WORK_DIR/hardened-template.yml" ] || [ -f "$WORK_DIR/hardened-template.yaml" ]; then
    pass "Hardened function configuration present"
else
    # Check for SAM/CloudFormation template
    if ls "$WORK_DIR"/*template* "$WORK_DIR"/*hardened* 2>/dev/null | grep -q .; then
        pass "Hardened deployment template present"
    else
        fail "No hardened function config found (expected hardened-function.json/yml or template in $WORK_DIR)"
    fi
fi

# Check 4: IAM policy review
IAM_REFS=$(grep -c -iE '(iam|least.privilege|policy|permission|role|overprivilege)' "$WORK_DIR"/*.* 2>/dev/null || echo 0)
if [ "$IAM_REFS" -ge 3 ]; then
    pass "IAM policy review documented ($IAM_REFS references)"
else
    fail "Insufficient IAM analysis (found $IAM_REFS references, need at least 3)"
fi

# Check 5: CloudWatch monitoring strategy
if grep -r -iE '(cloudwatch|duration|spike|anomal|network.call|metric|alarm|monitor)' "$WORK_DIR"/*.* 2>/dev/null | grep -qi .; then
    pass "CloudWatch monitoring strategy documented"
else
    fail "No CloudWatch monitoring strategy found"
fi

# Check 6: MITRE mapping present
MITRE_REFS=$(grep -c -E 'T1[0-9]{3}' "$WORK_DIR"/*.* 2>/dev/null || echo 0)
if [ "$MITRE_REFS" -ge 2 ]; then
    pass "MITRE ATT&CK mapping present ($MITRE_REFS technique references)"
else
    fail "Insufficient MITRE mapping (found $MITRE_REFS references, need at least 2)"
fi

echo ""
echo "=== Results: $PASS/$TOTAL passed ==="

if [ "$PASS" -eq "$TOTAL" ]; then
    echo "Lab 9.2 COMPLETE"
    exit 0
else
    echo "Lab 9.2 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

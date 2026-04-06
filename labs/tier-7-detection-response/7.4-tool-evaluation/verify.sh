#!/usr/bin/env bash
# Verify script for Lab 7.4: Supply Chain Security Tool Evaluation
# Checks that the learner evaluated tools and built a comparison matrix.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=5

pass() { echo "  PASS: $1"; ((PASS++)) || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true; }

echo "=== Lab 7.4: Tool Evaluation Verification ==="
echo ""

# Check 1: Comparison matrix exists
if [ -f "$WORK_DIR/comparison-matrix.md" ] || [ -f "$WORK_DIR/comparison-matrix.csv" ] || [ -f "$WORK_DIR/comparison-matrix.txt" ]; then
    pass "Comparison matrix document exists"
else
    fail "No comparison matrix found (expected comparison-matrix.md, .csv, or .txt in $WORK_DIR)"
fi

# Check 2: Matrix references at least 5 tools
TOOL_COUNT=0
for tool in "scorecard" "guac" "deps.dev" "dependabot" "snyk" "socket" "pip-audit" "npm.audit" "grype" "trivy"; do
    if grep -qi "$tool" "$WORK_DIR"/comparison-matrix.* 2>/dev/null; then
        ((TOOL_COUNT++)) || true
    fi
done

if [ "$TOOL_COUNT" -ge 5 ]; then
    pass "Matrix evaluates $TOOL_COUNT/10 tools (minimum 5)"
else
    fail "Matrix only references $TOOL_COUNT/10 tools (need at least 5)"
fi

# Check 3: Matrix covers attack types
ATTACK_COUNT=0
for attack in "dependency.confusion" "typosquat" "lockfile" "manifest" "phantom"; do
    if grep -qiE "$attack" "$WORK_DIR"/comparison-matrix.* 2>/dev/null; then
        ((ATTACK_COUNT++)) || true
    fi
done

if [ "$ATTACK_COUNT" -ge 3 ]; then
    pass "Matrix covers $ATTACK_COUNT/5 attack types (minimum 3)"
else
    fail "Matrix only covers $ATTACK_COUNT/5 attack types (need at least 3: dependency confusion, typosquatting, lockfile injection, manifest confusion, phantom dependencies)"
fi

# Check 4: Tool evaluation notes with actual output
if [ -f "$WORK_DIR/evaluation-notes.md" ] || [ -f "$WORK_DIR/evaluation-notes.txt" ]; then
    pass "Tool evaluation notes present"
else
    fail "No evaluation notes found (expected evaluation-notes.md or .txt in $WORK_DIR)"
fi

# Check 5: Recommendation document
if [ -f "$WORK_DIR/recommendation.md" ] || [ -f "$WORK_DIR/recommendation.txt" ]; then
    # Must include a recommendation with reasoning
    if grep -qiE '(recommend|adopt|implement|phase|rollout|priority)' "$WORK_DIR"/recommendation.* 2>/dev/null; then
        pass "Tool recommendation with adoption plan present"
    else
        fail "Recommendation file found but lacks specific recommendations"
    fi
else
    fail "No recommendation document found (expected recommendation.md or .txt in $WORK_DIR)"
fi

echo ""
echo "=== Results: $PASS/$TOTAL passed ==="

if [ "$PASS" -eq "$TOTAL" ]; then
    echo "Lab 7.4 COMPLETE"
    exit 0
else
    echo "Lab 7.4 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

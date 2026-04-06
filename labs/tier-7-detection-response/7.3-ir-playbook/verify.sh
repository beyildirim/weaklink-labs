#!/usr/bin/env bash
# Verify script for Lab 7.3: Incident Response Playbook
# Checks that the learner built a complete IR playbook and post-incident report template.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=5

pass() { echo "  PASS: $1"; ((PASS++)) || true || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true || true; }

echo "=== Lab 7.3: IR Playbook Verification ==="
echo ""

# Check 1: Playbook document exists
if [ -f "$WORK_DIR/ir-playbook.md" ] || [ -f "$WORK_DIR/ir-playbook.txt" ]; then
    pass "IR playbook document exists"
else
    fail "No IR playbook found (expected ir-playbook.md or .txt in $WORK_DIR)"
fi

# Check 2: Playbook covers all 6 NIST phases
NIST_PHASES=0
for phase in "preparation" "detection" "containment" "eradication" "recovery" "lessons"; do
    if grep -qi "$phase" "$WORK_DIR"/ir-playbook.* 2>/dev/null; then
        ((NIST_PHASES++)) || true || true
    fi
done

if [ "$NIST_PHASES" -ge 5 ]; then
    pass "Playbook covers $NIST_PHASES/6 NIST SP 800-61 phases"
else
    fail "Playbook only covers $NIST_PHASES/6 NIST phases (need at least 5: preparation, detection, containment, eradication, recovery, lessons learned)"
fi

# Check 3: Decision tree or escalation criteria present
if grep -qiE '(decision.tree|escalat|if.*then|flowchart|criteria|threshold|sev.?[0-9]|p[0-9])' "$WORK_DIR"/ir-playbook.* 2>/dev/null; then
    pass "Decision tree or escalation criteria present"
else
    fail "No decision tree or escalation criteria found in playbook"
fi

# Check 4: Playbook validated against 7.2 scenario
if [ -f "$WORK_DIR/walkthrough.md" ] || [ -f "$WORK_DIR/walkthrough.txt" ] || [ -f "$WORK_DIR/validation.md" ] || [ -f "$WORK_DIR/validation.txt" ]; then
    # Must reference the internal-utils@99.0.0 scenario
    if grep -qiE '(internal.utils|99\.0\.0|lab.7\.2|dependency.confusion)' "$WORK_DIR"/walkthrough.* "$WORK_DIR"/validation.* 2>/dev/null; then
        pass "Playbook validated against Lab 7.2 scenario"
    else
        fail "Walkthrough file exists but does not reference the Lab 7.2 incident scenario"
    fi
else
    fail "No playbook walkthrough/validation found (expected walkthrough.md or validation.md in $WORK_DIR)"
fi

# Check 5: Post-incident report template
if [ -f "$WORK_DIR/post-incident-template.md" ] || [ -f "$WORK_DIR/post-incident-report.md" ] || [ -f "$WORK_DIR/pir-template.md" ]; then
    # Must include sections for root cause, timeline, impact
    SECTIONS=0
    for keyword in "root.cause" "timeline" "impact" "action.items\|remediation\|follow.up"; do
        if grep -qiE "$keyword" "$WORK_DIR"/post-incident*.md "$WORK_DIR"/pir-template.md 2>/dev/null; then
            ((SECTIONS++)) || true || true
        fi
    done
    if [ "$SECTIONS" -ge 3 ]; then
        pass "Post-incident report template covers $SECTIONS/4 required sections"
    else
        fail "Post-incident report template found but only covers $SECTIONS/4 sections (need root cause, timeline, impact, action items)"
    fi
else
    fail "No post-incident report template found (expected post-incident-template.md or pir-template.md in $WORK_DIR)"
fi

echo ""
echo "=== Results: $PASS/$TOTAL passed ==="

if [ "$PASS" -eq "$TOTAL" ]; then
    echo "Lab 7.3 COMPLETE"
    exit 0
else
    echo "Lab 7.3 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

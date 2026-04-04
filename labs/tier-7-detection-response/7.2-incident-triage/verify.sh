#!/usr/bin/env bash
# Verify script for Lab 7.2: Supply Chain Incident Triage
# Checks that the learner investigated the incident, classified severity, and wrote an incident summary.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=5

pass() { echo "  PASS: $1"; ((PASS++)); }
fail() { echo "  FAIL: $1"; ((FAIL++)); }

echo "=== Lab 7.2: Incident Triage Verification ==="
echo ""

# Check 1: Investigation notes exist with scope analysis
if [ -f "$WORK_DIR/investigation.md" ] || [ -f "$WORK_DIR/investigation.txt" ]; then
    # Must reference pipeline/CI scope
    SCOPE_REFS=$(grep -c -iE '(pipeline|ci.run|build.job|runner|github.actions|gitlab)' "$WORK_DIR"/investigation.* 2>/dev/null || echo 0)
    if [ "$SCOPE_REFS" -ge 2 ]; then
        pass "Investigation notes contain scope analysis ($SCOPE_REFS pipeline references)"
    else
        fail "Investigation notes found but lack pipeline scope analysis (found $SCOPE_REFS references, need 2+)"
    fi
else
    fail "No investigation notes found (expected investigation.md or .txt in $WORK_DIR)"
fi

# Check 2: Blast radius analysis
if [ -f "$WORK_DIR/blast-radius.md" ] || [ -f "$WORK_DIR/blast-radius.txt" ]; then
    # Must identify affected systems/secrets
    SECRET_REFS=$(grep -c -iE '(secret|token|credential|api.key|aws|gcp|azure|npm_token|pypi_token|docker)' "$WORK_DIR"/blast-radius.* 2>/dev/null || echo 0)
    if [ "$SECRET_REFS" -ge 2 ]; then
        pass "Blast radius analysis identifies exposed secrets ($SECRET_REFS references)"
    else
        fail "Blast radius file found but lacks secret exposure analysis (found $SECRET_REFS references, need 2+)"
    fi
else
    fail "No blast radius analysis found (expected blast-radius.md or .txt in $WORK_DIR)"
fi

# Check 3: Severity classification
if grep -r -iE '(critical|high|severe|p1|sev.?1|sev.?2)' "$WORK_DIR"/investigation.* "$WORK_DIR"/incident-summary.* 2>/dev/null | grep -qiE '(severity|classification|priority)'; then
    pass "Severity classification found in investigation or incident summary"
else
    fail "No severity classification found -- must classify the incident severity"
fi

# Check 4: Incident summary for management
if [ -f "$WORK_DIR/incident-summary.md" ] || [ -f "$WORK_DIR/incident-summary.txt" ]; then
    # Must include recommended actions
    ACTION_REFS=$(grep -c -iE '(rotate|revoke|quarantine|block|disable|remediat|contain|isolat)' "$WORK_DIR"/incident-summary.* 2>/dev/null || echo 0)
    if [ "$ACTION_REFS" -ge 2 ]; then
        pass "Incident summary includes remediation actions ($ACTION_REFS action items)"
    else
        fail "Incident summary found but lacks remediation actions (found $ACTION_REFS, need 2+)"
    fi
else
    fail "No incident summary found (expected incident-summary.md or .txt in $WORK_DIR)"
fi

# Check 5: Timeline reconstruction
TIMELINE_REFS=$(grep -c -iE '([0-9]{2}:[0-9]{2}|hour|minute|T-[0-9]|timeline|timestamp|utc|ago)' "$WORK_DIR"/investigation.* "$WORK_DIR"/incident-summary.* 2>/dev/null || echo 0)
if [ "$TIMELINE_REFS" -ge 2 ]; then
    pass "Timeline reconstruction present ($TIMELINE_REFS time references)"
else
    fail "No incident timeline found -- must reconstruct the timeline of events"
fi

echo ""
echo "=== Results: $PASS/$TOTAL passed ==="

if [ "$PASS" -eq "$TOTAL" ]; then
    echo "Lab 7.2 COMPLETE"
    exit 0
else
    echo "Lab 7.2 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

#!/usr/bin/env bash
# Verify script for Lab 7.1: Building Detection Rules for Supply Chain Attacks
# Checks that the learner has created detection rules and validated them against sample logs.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=6

pass() { echo "  PASS: $1"; ((PASS++)) || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true; }

echo "=== Lab 7.1: Detection Rules Verification ==="
echo ""

# Check 1: Splunk detection rules file exists
if [ -f "$WORK_DIR/splunk-rules.spl" ] || [ -f "$WORK_DIR/splunk-rules.txt" ]; then
    # Verify it contains at least 3 queries (one per attack type minimum)
    QUERY_COUNT=$(grep -c -E '^\s*(index=|search |sourcetype=)' "$WORK_DIR"/splunk-rules.* 2>/dev/null || echo 0)
    if [ "$QUERY_COUNT" -ge 3 ]; then
        pass "Splunk rules file contains $QUERY_COUNT queries (minimum 3)"
    else
        fail "Splunk rules file found but contains only $QUERY_COUNT queries (need at least 3)"
    fi
else
    fail "No Splunk rules file found (expected splunk-rules.spl or splunk-rules.txt in $WORK_DIR)"
fi

# Check 2: KQL detection rules file exists
if [ -f "$WORK_DIR/kql-rules.kql" ] || [ -f "$WORK_DIR/kql-rules.txt" ]; then
    QUERY_COUNT=$(grep -c -E '^\s*(DeviceProcessEvents|SecurityAlert|DeviceNetworkEvents|DeviceFileEvents)' "$WORK_DIR"/kql-rules.* 2>/dev/null || echo 0)
    if [ "$QUERY_COUNT" -ge 3 ]; then
        pass "KQL rules file contains $QUERY_COUNT queries (minimum 3)"
    else
        fail "KQL rules file found but contains only $QUERY_COUNT queries (need at least 3)"
    fi
else
    fail "No KQL rules file found (expected kql-rules.kql or kql-rules.txt in $WORK_DIR)"
fi

# Check 3: Suricata rules file exists
if [ -f "$WORK_DIR/suricata.rules" ]; then
    RULE_COUNT=$(grep -c '^alert ' "$WORK_DIR/suricata.rules" 2>/dev/null || echo 0)
    if [ "$RULE_COUNT" -ge 2 ]; then
        pass "Suricata rules file contains $RULE_COUNT rules (minimum 2)"
    else
        fail "Suricata rules file found but contains only $RULE_COUNT rules (need at least 2)"
    fi
else
    fail "No Suricata rules file found (expected suricata.rules in $WORK_DIR)"
fi

# Check 4: Detection validation results exist (learner ran rules against sample logs)
if [ -f "$WORK_DIR/validation-results.md" ] || [ -f "$WORK_DIR/validation-results.txt" ]; then
    # Check that results reference at least 3 attack types
    ATTACK_REFS=$(grep -c -iE '(dependency.confusion|typosquat|lockfile|manifest.confusion|phantom)' "$WORK_DIR"/validation-results.* 2>/dev/null || echo 0)
    if [ "$ATTACK_REFS" -ge 3 ]; then
        pass "Validation results cover $ATTACK_REFS attack types (minimum 3)"
    else
        fail "Validation results found but only reference $ATTACK_REFS attack types (need at least 3)"
    fi
else
    fail "No validation results found (expected validation-results.md or .txt in $WORK_DIR)"
fi

# Check 5: False positive tuning notes exist
if [ -f "$WORK_DIR/tuning-notes.md" ] || [ -f "$WORK_DIR/tuning-notes.txt" ]; then
    pass "False positive tuning notes present"
else
    fail "No tuning notes found (expected tuning-notes.md or .txt in $WORK_DIR)"
fi

# Check 6: MITRE coverage matrix exists
if [ -f "$WORK_DIR/mitre-coverage.md" ] || [ -f "$WORK_DIR/mitre-coverage.txt" ] || [ -f "$WORK_DIR/mitre-coverage.csv" ]; then
    # Check that it references MITRE technique IDs
    MITRE_REFS=$(grep -c -E 'T1[0-9]{3}' "$WORK_DIR"/mitre-coverage.* 2>/dev/null || echo 0)
    if [ "$MITRE_REFS" -ge 3 ]; then
        pass "MITRE coverage matrix maps $MITRE_REFS technique references"
    else
        fail "MITRE coverage matrix found but only maps $MITRE_REFS technique references (need at least 3)"
    fi
else
    fail "No MITRE coverage matrix found (expected mitre-coverage.md, .txt, or .csv in $WORK_DIR)"
fi

echo ""
echo "=== Results: $PASS/$TOTAL passed ==="

if [ "$PASS" -eq "$TOTAL" ]; then
    echo "Lab 7.1 COMPLETE"
    exit 0
else
    echo "Lab 7.1 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

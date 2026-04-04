#!/usr/bin/env bash
# Verify script for Lab 9.4: IAM Chain Abuse
# Checks that the learner traced the trust chain, demonstrated escalation, and documented defenses.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=6

pass() { echo "  PASS: $1"; ((PASS++)); }
fail() { echo "  FAIL: $1"; ((FAIL++)); }

echo "=== Lab 9.4: IAM Chain Abuse Verification ==="
echo ""

# Check 1: Trust chain diagram or documentation exists
if [ -f "$WORK_DIR/trust-chain.md" ] || [ -f "$WORK_DIR/trust-chain.txt" ] || [ -f "$WORK_DIR/trust-chain-diagram.md" ]; then
    CHAIN_REFS=$(grep -c -iE '(dev|ci|staging|production|assume.?role|trust|account|cross.account)' "$WORK_DIR"/trust-chain*.* 2>/dev/null || echo 0)
    if [ "$CHAIN_REFS" -ge 4 ]; then
        pass "Trust chain documentation covers all four accounts ($CHAIN_REFS references)"
    else
        fail "Trust chain documented but incomplete (found $CHAIN_REFS account references, need 4+)"
    fi
else
    fail "No trust chain documentation found (expected trust-chain.md or .txt in $WORK_DIR)"
fi

# Check 2: Attack path walkthrough
if [ -f "$WORK_DIR/attack-path.md" ] || [ -f "$WORK_DIR/attack-path.txt" ]; then
    ESCALATION_REFS=$(grep -c -iE '(escalat|pivot|travers|hop|compromise|credential|assume|impersonat)' "$WORK_DIR"/attack-path.* 2>/dev/null || echo 0)
    if [ "$ESCALATION_REFS" -ge 3 ]; then
        pass "Attack path walkthrough documents escalation ($ESCALATION_REFS references)"
    else
        fail "Attack path found but lacks escalation detail (found $ESCALATION_REFS references, need 3+)"
    fi
else
    fail "No attack path walkthrough found (expected attack-path.md or .txt in $WORK_DIR)"
fi

# Check 3: Hardened trust policies exist
if [ -f "$WORK_DIR/hardened-trust-policy.json" ] || [ -f "$WORK_DIR/hardened-policies.json" ] || [ -f "$WORK_DIR/hardened-trust-policy.md" ]; then
    pass "Hardened trust policies documented"
else
    if grep -r -iE '(external.?id|condition|oidc|source.?ip|source.?account)' "$WORK_DIR"/*.* 2>/dev/null | grep -qi 'trust\|policy\|role'; then
        pass "Hardened trust policy conditions found in documentation"
    else
        fail "No hardened trust policies found (expected hardened-trust-policy.json or conditions in documentation)"
    fi
fi

# Check 4: OIDC federation recommendation
if grep -r -iE '(oidc|federation|identity.provider|openid|workload.identity)' "$WORK_DIR"/*.* 2>/dev/null | grep -qi .; then
    pass "OIDC federation recommendation documented"
else
    fail "No OIDC federation recommendation found -- must recommend replacing long-lived credentials"
fi

# Check 5: CloudTrail detection queries
DETECT_REFS=$(grep -c -iE '(cloudtrail|assume.?role|cross.account|source.?account|time.of.day|anomal|unusual)' "$WORK_DIR"/*.* 2>/dev/null || echo 0)
if [ "$DETECT_REFS" -ge 3 ]; then
    pass "CloudTrail detection strategy documented ($DETECT_REFS references)"
else
    fail "Insufficient CloudTrail detection coverage (found $DETECT_REFS references, need at least 3)"
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
    echo "Lab 9.4 COMPLETE"
    exit 0
else
    echo "Lab 9.4 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

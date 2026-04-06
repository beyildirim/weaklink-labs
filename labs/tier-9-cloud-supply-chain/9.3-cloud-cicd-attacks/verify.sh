#!/usr/bin/env bash
# Verify script for Lab 9.3: Cloud CI/CD Attacks (Beyond GitHub Actions)
# Checks that the learner analyzed all three attack vectors and documented hardened configurations.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=6

pass() { echo "  PASS: $1"; ((PASS++)) || true; }
fail() { echo "  FAIL: $1"; ((FAIL++)) || true; }

echo "=== Lab 9.3: Cloud CI/CD Attacks Verification ==="
echo ""

# Check 1: CodeBuild env variable injection analysis
if grep -r -iE '(codebuild|buildspec|ssm|parameter.store|environment.variable|env.inject)' "$WORK_DIR"/*.* 2>/dev/null | grep -qi .; then
    pass "CodeBuild environment variable injection analysis documented"
else
    fail "No CodeBuild attack analysis found -- must analyze buildspec.yml SSM parameter injection"
fi

# Check 2: Cloud Build substitution abuse analysis
if grep -r -iE '(cloud.build|cloudbuild|substitution|_[A-Z_]+|user.controlled)' "$WORK_DIR"/*.* 2>/dev/null | grep -qi .; then
    pass "Cloud Build substitution variable abuse analysis documented"
else
    fail "No Cloud Build attack analysis found -- must analyze cloudbuild.yaml substitution abuse"
fi

# Check 3: Overprivileged build role analysis
if grep -r -iE '(overprivilege|admin.access|escalat|build.role|codebuild.role|service.role|iam.policy)' "$WORK_DIR"/*.* 2>/dev/null | grep -qi .; then
    pass "Overprivileged build role analysis documented"
else
    fail "No privilege escalation analysis found -- must analyze overprivileged build service roles"
fi

# Check 4: Hardened build configurations exist
HARDENED_COUNT=0
for pattern in "hardened" "secure" "fixed" "remediat"; do
    if ls "$WORK_DIR"/*${pattern}* 2>/dev/null | grep -q .; then
        ((HARDENED_COUNT++))
    fi
done
if [ "$HARDENED_COUNT" -ge 1 ]; then
    pass "Hardened build configuration(s) present"
else
    # Fallback: check for any buildspec or cloudbuild files in work dir
    if ls "$WORK_DIR"/*buildspec* "$WORK_DIR"/*cloudbuild* 2>/dev/null | grep -q .; then
        pass "Build configuration files present in work directory"
    else
        fail "No hardened build configurations found (expected files with 'hardened', 'secure', or build config names in $WORK_DIR)"
    fi
fi

# Check 5: Detection strategy with CloudTrail focus
DETECT_REFS=$(grep -c -iE '(cloudtrail|ssm.getparameter|iam.access.analyzer|build.duration|anomal|detect)' "$WORK_DIR"/*.* 2>/dev/null || echo 0)
if [ "$DETECT_REFS" -ge 3 ]; then
    pass "Detection strategy documented ($DETECT_REFS relevant references)"
else
    fail "Insufficient detection strategy (found $DETECT_REFS references, need at least 3)"
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
    echo "Lab 9.3 COMPLETE"
    exit 0
else
    echo "Lab 9.3 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

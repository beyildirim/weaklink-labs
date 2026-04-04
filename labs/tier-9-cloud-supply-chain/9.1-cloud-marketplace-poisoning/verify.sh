#!/usr/bin/env bash
# Verify script for Lab 9.1: Cloud Marketplace Poisoning
# Checks that the learner identified backdoors, built a clean image, and documented detection strategies.

set -euo pipefail

LAB_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${WEAKLINK_WORK_DIR:-$LAB_DIR/work}"
PASS=0
FAIL=0
TOTAL=6

pass() { echo "  PASS: $1"; ((PASS++)); }
fail() { echo "  FAIL: $1"; ((FAIL++)); }

echo "=== Lab 9.1: Cloud Marketplace Poisoning Verification ==="
echo ""

# Check 1: Backdoor analysis report exists
if [ -f "$WORK_DIR/backdoor-analysis.md" ] || [ -f "$WORK_DIR/backdoor-analysis.txt" ]; then
    BACKDOOR_REFS=$(grep -c -iE '(cron|ssh|systemd|authorized_keys|reverse.shell|phone.home|backdoor)' "$WORK_DIR"/backdoor-analysis.* 2>/dev/null || echo 0)
    if [ "$BACKDOOR_REFS" -ge 3 ]; then
        pass "Backdoor analysis identifies $BACKDOOR_REFS persistence mechanisms (minimum 3)"
    else
        fail "Backdoor analysis found but only identifies $BACKDOOR_REFS mechanisms (need at least 3)"
    fi
else
    fail "No backdoor analysis found (expected backdoor-analysis.md or .txt in $WORK_DIR)"
fi

# Check 2: Clean Dockerfile or IaC exists (learner built from scratch)
if [ -f "$WORK_DIR/Dockerfile" ] || [ -f "$WORK_DIR/Dockerfile.clean" ] || [ -f "$WORK_DIR/packer.json" ] || [ -f "$WORK_DIR/packer.pkr.hcl" ]; then
    pass "Clean base image definition found (Dockerfile or Packer config)"
else
    fail "No clean image definition found (expected Dockerfile, Dockerfile.clean, or packer config in $WORK_DIR)"
fi

# Check 3: Image scan results exist
if [ -f "$WORK_DIR/scan-results.md" ] || [ -f "$WORK_DIR/scan-results.txt" ] || [ -f "$WORK_DIR/scan-results.json" ]; then
    SCAN_REFS=$(grep -c -iE '(trivy|grype|syft|snyk|vulnerability|CVE|cron|ssh|backdoor)' "$WORK_DIR"/scan-results.* 2>/dev/null || echo 0)
    if [ "$SCAN_REFS" -ge 2 ]; then
        pass "Image scan results reference scanning tools or findings ($SCAN_REFS references)"
    else
        fail "Scan results found but lack tool references or findings (found $SCAN_REFS, need 2+)"
    fi
else
    fail "No image scan results found (expected scan-results.md, .txt, or .json in $WORK_DIR)"
fi

# Check 4: Detection strategy document exists
if [ -f "$WORK_DIR/detection-strategy.md" ] || [ -f "$WORK_DIR/detection-strategy.txt" ]; then
    DETECT_REFS=$(grep -c -iE '(cloudtrail|audit.log|outbound|connection|cron|authorized_keys|monitoring)' "$WORK_DIR"/detection-strategy.* 2>/dev/null || echo 0)
    if [ "$DETECT_REFS" -ge 3 ]; then
        pass "Detection strategy covers $DETECT_REFS detection vectors (minimum 3)"
    else
        fail "Detection strategy found but only covers $DETECT_REFS vectors (need at least 3)"
    fi
else
    fail "No detection strategy found (expected detection-strategy.md or .txt in $WORK_DIR)"
fi

# Check 5: SSH key audit performed
if grep -r -iE '(authorized_keys|ssh.key|ssh.config|sshd_config|PermitRootLogin)' "$WORK_DIR"/*.* 2>/dev/null | grep -qi 'ssh'; then
    pass "SSH configuration audit documented"
else
    fail "No SSH audit evidence found -- must check authorized_keys and sshd_config"
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
    echo "Lab 9.1 COMPLETE"
    exit 0
else
    echo "Lab 9.1 INCOMPLETE -- $FAIL checks failed"
    exit 1
fi

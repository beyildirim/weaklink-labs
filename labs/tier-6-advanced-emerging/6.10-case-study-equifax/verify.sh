#!/bin/bash
#
# Verification script for Lab 6.10: Case Study - Equifax Breach (CVE-2017-5638)
# Checks understanding and defensive measures.
#

set -uo pipefail

PASS=0
FAIL=0

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
echo "  Verifying Lab 6.10: Case Study - Equifax Breach (CVE-2017-5638)"
echo "  ================================================================="
echo ""

# Check 1: Patch compliance checklist exists
check "Patch compliance checklist exists" \
    "test -f /app/patch-compliance-checklist.md && grep -qi 'patch\|remediation\|SLA' /app/patch-compliance-checklist.md"

# Check 2: Analysis covers the Struts vulnerability
check "Analysis covers Apache Struts CVE-2017-5638" \
    "test -f /app/analysis.md && grep -qi 'struts' /app/analysis.md && grep -qi 'content.type\|Content-Type' /app/analysis.md"

# Check 3: Analysis covers the timeline and process failure
check "Analysis covers the 2-month patching failure" \
    "test -f /app/analysis.md && grep -qi 'patch\|remediat' /app/analysis.md && grep -qi 'march\|may\|july\|78.*day\|two.*month' /app/analysis.md"

# Check 4: WAF rules for Struts detection exist
check "WAF rules detect Struts Content-Type exploitation" \
    "test -f /app/waf-rules.conf && grep -qi 'struts\|content.type\|ognl\|multipart' /app/waf-rules.conf"

# Check 5: Dependency monitoring configuration exists
check "Dependency version monitoring is configured" \
    "test -f /app/dependency-monitor.yml && grep -qi 'struts\|version\|alert' /app/dependency-monitor.yml"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

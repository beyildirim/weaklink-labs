#!/bin/bash
#
# Verification script for Lab 6.9: Case Study - Log4Shell (CVE-2021-44228)
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
echo "  Verifying Lab 6.9: Case Study - Log4Shell (CVE-2021-44228)"
echo "  ============================================================"
echo ""

# Check 1: SBOM exists and shows Log4j dependency path
check "SBOM shows Log4j as a transitive dependency" \
    "test -f /app/sbom.json && grep -qi 'log4j' /app/sbom.json"

# Check 2: WAF rules for JNDI detection exist
check "WAF rules detect JNDI lookup patterns" \
    "test -f /app/waf-rules.conf && grep -qi 'jndi' /app/waf-rules.conf"

# Check 3: Analysis document covers the attack mechanism
check "Analysis covers JNDI lookup attack mechanism" \
    "test -f /app/analysis.md && grep -qi 'jndi' /app/analysis.md && grep -qi 'ldap\|rmi' /app/analysis.md"

# Check 4: Dependency tree analysis shows transitive path
check "Dependency tree analysis identifies transitive Log4j inclusion" \
    "test -f /app/dependency-tree.txt && grep -qi 'log4j\|log4j-core' /app/dependency-tree.txt"

# Check 5: Detection queries exist for JNDI patterns
check "Detection queries cover JNDI pattern matching in logs" \
    "test -f /app/detection-queries.txt && grep -Eqi 'jndi|\\$\\{' /app/detection-queries.txt"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

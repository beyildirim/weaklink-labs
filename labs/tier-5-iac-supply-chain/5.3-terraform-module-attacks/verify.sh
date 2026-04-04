#!/bin/bash
#
# Verification script for Lab 5.3: Terraform Module and Provider Attacks
# Checks that the user has identified and removed the malicious provisioner
# and pinned module versions.
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
echo "  Verifying Lab 5.3: Terraform Module and Provider Attacks"
echo "  ========================================================="
echo ""

# Check 1: No local-exec provisioners remain in modules
check "No local-exec provisioners in Terraform modules" \
    "! grep -r 'local-exec' /app/infra/modules/"

# Check 2: Module source uses pinned version (not latest)
check "Module source uses pinned version or local path" \
    "grep -E '(version\s*=|\.\/modules\/)' /app/infra/main.tf"

# Check 3: .terraform.lock.hcl exists with provider hashes
check "Terraform lock file exists with provider hashes" \
    "test -f /app/infra/.terraform.lock.hcl && grep -q 'h1:' /app/infra/.terraform.lock.hcl"

# Check 4: No exfiltration patterns in any .tf file
check "No curl/wget/exfiltration commands in .tf files" \
    "! grep -r -E '(curl|wget|nc |ncat|/dev/tcp)' /app/infra/ --include='*.tf'"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

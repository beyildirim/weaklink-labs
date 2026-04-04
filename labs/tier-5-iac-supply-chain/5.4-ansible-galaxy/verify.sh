#!/bin/bash
#
# Verification script for Lab 5.4: Ansible Galaxy and Collection Attacks
# Checks that the user has identified the backdoor and secured role installation.
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
echo "  Verifying Lab 5.4: Ansible Galaxy and Collection Attacks"
echo "  ========================================================="
echo ""

# Check 1: Malicious authorized_keys task removed from role
check "No SSH key injection in ntp role tasks" \
    "! grep -r 'authorized_keys' /app/roles/ntp_config/tasks/"

# Check 2: requirements.yml uses version pins
check "requirements.yml pins role versions" \
    "grep -q 'version:' /app/requirements.yml"

# Check 3: No backdoor SSH key present
check "No attacker SSH key in authorized_keys tasks" \
    "! grep -r 'AAAAB3NzaC1' /app/roles/ntp_config/"

# Check 4: Playbook is clean and only configures NTP
check "Playbook only contains NTP-related tasks" \
    "! grep -r -E '(authorized_keys|\.ssh|id_rsa)' /app/playbooks/configure-servers.yml"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

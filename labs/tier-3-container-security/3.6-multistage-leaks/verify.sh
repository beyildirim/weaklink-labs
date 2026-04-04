#!/bin/bash
#
# Verification script for Lab 3.6: Multi-Stage Build Leaks
# Runs INSIDE the workstation pod via kubectl exec.
# Checks that the user has eliminated secret leakage from multi-stage builds.
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
echo "  Verifying Lab 3.6: Multi-Stage Build Leaks"
echo "  ============================================"
echo ""

# Check 1: Fixed Dockerfile does not use ENV or ARG for secrets
check "Dockerfile does not use ENV/ARG for secrets" \
    "! grep -Ei '(ENV|ARG).*(SECRET|API_KEY|TOKEN|PASSWORD)' /app/Dockerfile.fixed"

# Check 2: Fixed Dockerfile uses BuildKit secret mount
check "Dockerfile uses --mount=type=secret for sensitive data" \
    "grep -q 'mount=type=secret' /app/Dockerfile.fixed"

# Check 3: Final image does not contain the secret in any layer
check "Secret not present in final image layers" \
    "docker history --no-trunc registry:5000/myapp:secure 2>/dev/null | grep -vi 'SECRET_API_KEY\|s3cr3t_k3y' && ! docker run --rm registry:5000/myapp:secure env 2>/dev/null | grep -q 'SECRET_API_KEY'"

# Check 4: .dockerignore exists and blocks sensitive files
check ".dockerignore blocks sensitive files" \
    "test -f /app/.dockerignore && grep -qE '\.env|\.secret|credentials' /app/.dockerignore"

echo ""
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0

#!/bin/bash
# Verification script for Lab 0.3: How Containers Work
# Checks that the student has:
#   1. A Dockerfile that uses digest pinning (not tag)
#   2. The defended image was built
#   3. The safe digest is referenced (not the backdoored image)

set -uo pipefail

PASS=0
FAIL=0

check() {
    local description="$1"
    local result="$2"
    if [ "$result" -eq 0 ]; then
        echo "  PASS: ${description}"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: ${description}"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "=== Lab 0.3 Verification: How Containers Work ==="
echo ""

# Check workspace is running
WORKSPACE_RUNNING=$(docker compose ps --format json 2>/dev/null | grep -c '"workspace"' || true)
if [ "${WORKSPACE_RUNNING}" -eq 0 ]; then
    echo "  FAIL: Workspace container is not running. Start the lab first: docker compose up -d"
    exit 1
fi

# Check 1: Registry is running
echo "[*] Checking local registry..."
if curl -sf "http://localhost:5000/v2/" > /dev/null 2>&1; then
    check "Local registry is running" 0
else
    check "Local registry is running" 1
fi

# Check 2: A Dockerfile with digest pinning exists
echo "[*] Checking for Dockerfile with digest pinning..."
HAS_DIGEST_PIN=$(docker compose exec -T workspace sh -c "grep -c '@sha256:' /workspace/Dockerfile.defended 2>/dev/null || echo 0" 2>/dev/null)
if [ "${HAS_DIGEST_PIN}" -gt 0 ] 2>/dev/null; then
    check "Dockerfile.defended uses digest pinning (@sha256:...)" 0
else
    check "Dockerfile.defended uses digest pinning (@sha256:...)" 1
fi

# Check 3: Dockerfile does NOT use :latest tag
echo "[*] Checking that Dockerfile does not use :latest..."
USES_LATEST=$(docker compose exec -T workspace sh -c "grep -c ':latest' /workspace/Dockerfile.defended 2>/dev/null || echo 0" 2>/dev/null)
if [ "${USES_LATEST}" -eq 0 ] 2>/dev/null; then
    check "Dockerfile.defended does not reference :latest tag" 0
else
    check "Dockerfile.defended does not reference :latest tag" 1
fi

# Check 4: The safe digest is used (not the backdoored one)
echo "[*] Checking that the Dockerfile pins to the safe digest..."
SAFE_DIGEST=$(docker compose exec -T workspace sh -c "cat /workspace/safe-digest.txt 2>/dev/null" 2>/dev/null | tr -d '[:space:]')
if [ -n "${SAFE_DIGEST}" ]; then
    DIGEST_IN_FILE=$(docker compose exec -T workspace sh -c "grep -c '${SAFE_DIGEST}' /workspace/Dockerfile.defended 2>/dev/null || echo 0" 2>/dev/null)
    if [ "${DIGEST_IN_FILE}" -gt 0 ] 2>/dev/null; then
        check "Dockerfile.defended references the safe image digest" 0
    else
        check "Dockerfile.defended references the safe image digest" 1
    fi
else
    echo "  SKIP: Could not read safe digest file"
fi

# Check 5: The defended image was built
echo "[*] Checking that the defended image was built..."
IMAGE_EXISTS=$(docker compose exec -T workspace sh -c "docker images -q my-defended-app:v1 2>/dev/null | head -1" 2>/dev/null)
if [ -n "${IMAGE_EXISTS}" ] && [ "${IMAGE_EXISTS}" != "" ]; then
    check "Defended image 'my-defended-app:v1' was built" 0
else
    check "Defended image 'my-defended-app:v1' was built" 1
fi

# Summary
echo ""
echo "=== Results ==="
echo "  Passed: ${PASS}"
echo "  Failed: ${FAIL}"
echo ""

if [ "${FAIL}" -eq 0 ]; then
    echo "  ALL CHECKS PASSED -- Lab 0.3 complete!"
    echo ""
    exit 0
else
    echo "  Some checks failed. Review the steps in README.md and try again."
    echo ""
    exit 1
fi

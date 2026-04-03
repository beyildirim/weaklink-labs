#!/bin/bash
# Verification script for Lab 1.5: Manifest Confusion
# Checks that the student has completed the DEFEND phase.

set -uo pipefail

PASS=0
FAIL=0
WORKSPACE="/workspace"

echo "=== Lab 1.5: Manifest Confusion — Verification ==="
echo ""

# Check 1: /tmp/manifest-confusion-pwned does NOT exist
echo -n "[Check 1] No compromise marker (/tmp/manifest-confusion-pwned)... "
if [ ! -f /tmp/manifest-confusion-pwned ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL — /tmp/manifest-confusion-pwned exists. Remove it and reinstall without evil-pkg."
    FAIL=$((FAIL + 1))
fi

# Check 2: evil-pkg is NOT in node_modules
echo -n "[Check 2] evil-pkg not in node_modules... "
if [ ! -d "${WORKSPACE}/node_modules/evil-pkg" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL — evil-pkg is still in node_modules/. Reinstall using only safe dependencies."
    FAIL=$((FAIL + 1))
fi

# Check 3: package-lock.json exists with integrity hashes
echo -n "[Check 3] package-lock.json exists with integrity hashes... "
if [ -f "${WORKSPACE}/package-lock.json" ]; then
    if grep -q '"integrity"' "${WORKSPACE}/package-lock.json"; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL — package-lock.json exists but has no integrity hashes."
        FAIL=$((FAIL + 1))
    fi
else
    echo "FAIL — package-lock.json not found in ${WORKSPACE}/."
    FAIL=$((FAIL + 1))
fi

# Check 4: Manifest comparison script exists and is executable
echo -n "[Check 4] Manifest comparison tool available... "
if command -v compare-manifests >/dev/null 2>&1 || [ -x "${WORKSPACE}/check-manifest.sh" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL — No manifest comparison tool found. Use the provided compare-manifests or write check-manifest.sh."
    FAIL=$((FAIL + 1))
fi

# Summary
echo ""
echo "=== Results ==="
echo "Passed: ${PASS}/4"
echo "Failed: ${FAIL}/4"
echo ""

if [ "${FAIL}" -eq 0 ]; then
    echo "Lab 1.5 COMPLETE. You can detect and defend against manifest confusion attacks."
    exit 0
else
    echo "Lab 1.5 INCOMPLETE. Fix the failing checks and re-run verification."
    exit 1
fi

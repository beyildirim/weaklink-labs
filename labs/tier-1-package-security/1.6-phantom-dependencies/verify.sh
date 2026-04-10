#!/bin/bash
# Verification script for Lab 1.6: Phantom Dependencies
# Checks that the student has completed the DEFEND phase.

set -uo pipefail

PASS=0
FAIL=0
WORKSPACE="/app"

echo "=== Lab 1.6: Phantom Dependencies — Verification ==="
echo ""

# Check 1: depcheck reports no phantom deps (or debug is in package.json)
echo -n "[Check 1] No phantom dependencies (debug in package.json)... "
if [ -f "${WORKSPACE}/package.json" ]; then
    if node -pe "
const pkg = JSON.parse(require('fs').readFileSync('${WORKSPACE}/package.json','utf8'));
const deps = pkg.dependencies || {};
deps['debug'] ? 'yes' : 'no'
" 2>/dev/null | grep -q "yes"; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "FAIL — 'debug' is not in package.json dependencies."
        FAIL=$((FAIL + 1))
    fi
else
    echo "FAIL — package.json not found."
    FAIL=$((FAIL + 1))
fi

# Check 2: debug is in package.json with a safe version (not 99.x)
echo -n "[Check 2] debug version is safe (not malicious 99.x)... "
if [ -f "${WORKSPACE}/package.json" ]; then
    DEBUG_VER=$(node -pe "
const pkg = JSON.parse(require('fs').readFileSync('${WORKSPACE}/package.json','utf8'));
(pkg.dependencies || {})['debug'] || 'none'
" 2>/dev/null)
    if echo "${DEBUG_VER}" | grep -q "99"; then
        echo "FAIL — debug version points to the malicious package (${DEBUG_VER})."
        FAIL=$((FAIL + 1))
    elif [ "${DEBUG_VER}" = "none" ]; then
        echo "FAIL — debug is not in dependencies."
        FAIL=$((FAIL + 1))
    else
        echo "PASS (${DEBUG_VER})"
        PASS=$((PASS + 1))
    fi
else
    echo "FAIL — package.json not found."
    FAIL=$((FAIL + 1))
fi

# Check 3: The app runs successfully
echo -n "[Check 3] App starts successfully... "
if [ -f "${WORKSPACE}/app.js" ]; then
    # Run the app for 2 seconds and check for errors
    cd "${WORKSPACE}"
    OUTPUT=$(timeout 3 node app.js 2>&1) || true
    if echo "${OUTPUT}" | grep -q "Cannot find module"; then
        echo "FAIL — App crashes: missing module."
        FAIL=$((FAIL + 1))
    elif echo "${OUTPUT}" | grep -qi "error"; then
        echo "FAIL — App has errors: ${OUTPUT}"
        FAIL=$((FAIL + 1))
    else
        echo "PASS"
        PASS=$((PASS + 1))
    fi
else
    echo "FAIL — app.js not found."
    FAIL=$((FAIL + 1))
fi

# Check 4: package-lock.json exists
echo -n "[Check 4] package-lock.json exists... "
if [ -f "${WORKSPACE}/package-lock.json" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
else
    echo "FAIL — package-lock.json not found. Run npm install to generate it."
    FAIL=$((FAIL + 1))
fi

# Summary
echo ""
echo "=== Results ==="
echo "Passed: ${PASS}/4"
echo "Failed: ${FAIL}/4"
echo ""

if [ "${FAIL}" -eq 0 ]; then
    echo "Lab 1.6 COMPLETE. You understand phantom dependencies and how to defend against them."
    exit 0
else
    echo "Lab 1.6 INCOMPLETE. Fix the failing checks and re-run verification."
    exit 1
fi

#!/bin/bash
# compare-manifests.sh — Defense tool for detecting manifest confusion
#
# Compares what the registry API reports (npm view) against what's
# actually inside the package tarball (npm pack + extract).
#
# Usage: ./compare-manifests.sh <package-name> [registry-url]

set -euo pipefail

PKG="${1:?Usage: $0 <package-name> [registry-url]}"
REGISTRY="${2:-http://verdaccio:4873}"

WORKDIR=$(mktemp -d)
trap "rm -rf ${WORKDIR}" EXIT

echo "=== Manifest Comparison: ${PKG} ==="
echo ""

# --- Get registry metadata ---
echo "[1] Fetching registry metadata..."
REGISTRY_META="${WORKDIR}/registry-meta.json"
curl -sf "${REGISTRY}/${PKG}" | node -pe "
const pkg = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
const latest = pkg.versions[pkg['dist-tags'].latest];
JSON.stringify({
    name: latest.name,
    version: latest.version,
    dependencies: latest.dependencies || {},
    devDependencies: latest.devDependencies || {},
    scripts: latest.scripts || {},
    bin: latest.bin || {}
}, null, 2)
" > "${REGISTRY_META}"

echo "   Registry says:"
cat "${REGISTRY_META}" | sed 's/^/     /'
echo ""

# --- Get actual tarball contents ---
echo "[2] Downloading and extracting tarball..."
cd "${WORKDIR}"
npm pack "${PKG}" --registry "${REGISTRY}" 2>/dev/null

TARBALL=$(ls *.tgz 2>/dev/null | head -1)
if [ -z "${TARBALL}" ]; then
    echo "[-] Failed to download tarball"
    exit 1
fi

tar xzf "${TARBALL}"
TARBALL_META="${WORKDIR}/tarball-meta.json"
node -pe "
const pkg = JSON.parse(require('fs').readFileSync('package/package.json','utf8'));
JSON.stringify({
    name: pkg.name,
    version: pkg.version,
    dependencies: pkg.dependencies || {},
    devDependencies: pkg.devDependencies || {},
    scripts: pkg.scripts || {},
    bin: pkg.bin || {}
}, null, 2)
" > "${TARBALL_META}"

echo "   Tarball says:"
cat "${TARBALL_META}" | sed 's/^/     /'
echo ""

# --- Compare ---
echo "[3] Comparing..."
echo ""

DIFF_OUTPUT=$(diff --unified "${REGISTRY_META}" "${TARBALL_META}" 2>&1) || true

if [ -z "${DIFF_OUTPUT}" ]; then
    echo "    [CLEAN] Registry metadata matches tarball contents."
    echo ""
    exit 0
else
    echo "    [MISMATCH] Registry metadata does NOT match tarball contents!"
    echo ""
    echo "    Differences (--- registry, +++ tarball):"
    echo "${DIFF_OUTPUT}" | sed 's/^/     /'
    echo ""
    echo "    [!] WARNING: This package may have been tampered with."
    echo "    [!] Do NOT install it without further investigation."
    echo ""
    exit 1
fi

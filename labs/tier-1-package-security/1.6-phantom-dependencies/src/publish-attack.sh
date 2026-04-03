#!/bin/bash
# publish-attack.sh — Phase 2 attack setup for Lab 1.6
#
# Publishes:
# 1. acme-framework@2.0.0 (drops the debug dependency)
# 2. debug@99.0.0 (malicious version that simulates an attacker takeover)
#
# After running this, `npm update` in the victim app will:
# - Upgrade acme-framework to v2.0.0 (which no longer depends on debug)
# - Potentially resolve debug@99.0.0 (the malicious version)

set -euo pipefail

REGISTRY="http://registry:4873"
PACKAGES_DIR="/lab/src/packages"

echo "=== Publishing attack packages ==="

# Re-authenticate
TOKEN=$(curl -sf -X PUT "${REGISTRY}/-/user/org.couchdb.user:labuser" \
    -H "Content-Type: application/json" \
    -d '{"name":"labuser","password":"labpass123"}' | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).token")

echo "//registry:4873/:_authToken=${TOKEN}" > ~/.npmrc
echo "registry=${REGISTRY}/" >> ~/.npmrc

# Publish acme-framework@2.0.0 (no debug dependency)
echo ""
echo "[1] Publishing acme-framework@2.0.0 (debug dependency REMOVED)..."
cd "${PACKAGES_DIR}/acme-framework/v2"
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] acme-framework@2.0.0 published"

# Publish malicious debug@99.0.0
echo ""
echo "[2] Publishing debug@99.0.0 (MALICIOUS)..."
cd "${PACKAGES_DIR}/debug-malicious"
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] debug@99.0.0 published (malicious)"

echo ""
echo "=== Attack packages ready ==="
echo ""
echo "Now in the victim app, run:"
echo "  npm update"
echo ""
echo "This will upgrade acme-framework to v2.0.0 and may resolve debug@99.0.0."

#!/bin/bash
# Setup script for Lab 1.6: Phantom Dependencies
# Publishes packages to the local Verdaccio registry.
#
# Initial state: only acme-framework@1.0.0 is published (which depends on debug).
# The malicious debug@99.0.0 and acme-framework@2.0.0 are published later during
# the BREAK phase via publish-attack.sh.

set -euo pipefail

REGISTRY="http://registry:4873"
PACKAGES_DIR="/lab/src/packages"

echo "=== Waiting for Verdaccio registry ==="
until curl -sf "${REGISTRY}/-/ping" > /dev/null 2>&1; do
    sleep 1
done
echo "[+] Registry is up"

# Authenticate
echo "=== Authenticating ==="
TOKEN=$(curl -sf -X PUT "${REGISTRY}/-/user/org.couchdb.user:labuser" \
    -H "Content-Type: application/json" \
    -d '{"name":"labuser","password":"labpass123"}' | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).token")

echo "//registry:4873/:_authToken=${TOKEN}" > ~/.npmrc
echo "registry=${REGISTRY}/" >> ~/.npmrc
echo "[+] Authenticated"

# Publish the real debug package (v4.3.4 from npm)
# We need the real debug for acme-framework v1 to work
echo ""
echo "=== Publishing debug@4.3.4 (real package) ==="
WORK=$(mktemp -d)
cd "${WORK}"
cat > package.json << 'EOF'
{
  "name": "debug",
  "version": "4.3.4",
  "description": "Lightweight debugging utility",
  "main": "index.js",
  "dependencies": {
    "ms": "2.1.2"
  }
}
EOF
cat > index.js << 'JSEOF'
// Simplified debug module (mimics real debug@4.3.4 API)
module.exports = function createDebug(namespace) {
    const fn = function(...args) {
        if (process.env.DEBUG && (process.env.DEBUG === '*' || process.env.DEBUG.includes(namespace.split(':')[0]))) {
            const prefix = `  ${namespace}`;
            console.error(prefix, ...args);
        }
    };
    fn.enabled = true;
    fn.namespace = namespace;
    fn.extend = (sub) => createDebug(`${namespace}:${sub}`);
    return fn;
};
module.exports.default = module.exports;
JSEOF
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] debug@4.3.4 published"

# Publish ms@2.1.2 (dependency of debug)
echo ""
echo "=== Publishing ms@2.1.2 ==="
cd "${WORK}"
rm -rf *
cat > package.json << 'EOF'
{
  "name": "ms",
  "version": "2.1.2",
  "description": "Tiny millisecond conversion utility",
  "main": "index.js"
}
EOF
cat > index.js << 'JSEOF'
module.exports = function(val) { return val; };
JSEOF
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] ms@2.1.2 published"

# Publish acme-framework@1.0.0 (depends on debug)
echo ""
echo "=== Publishing acme-framework@1.0.0 ==="
cd "${PACKAGES_DIR}/acme-framework/v1"
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] acme-framework@1.0.0 published (depends on debug@4.3.4)"

# Clean up
rm -rf "${WORK}"

echo ""
echo "=== Initial registry setup complete ==="
echo ""
echo "Packages available:"
echo "  - debug@4.3.4 (real, safe)"
echo "  - ms@2.1.2"
echo "  - acme-framework@1.0.0 (depends on debug)"
echo ""
echo "Packages NOT yet published (for Phase 2):"
echo "  - acme-framework@2.0.0 (drops debug dependency)"
echo "  - debug@99.0.0 (malicious)"

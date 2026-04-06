#!/bin/bash
#
# WeakLink Labs — Registry Seeder
# Seeds PyPI private/public, Verdaccio, Gitea, and OCI registry
# with all lab content.
#
set -euo pipefail

# ============================================================
# Helpers
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${CYAN}[*]${NC} $*"; }
ok()   { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[-]${NC} $*"; }

wait_for_service() {
    local name="$1"
    local url="$2"
    local max_wait="${3:-120}"

    log "Waiting for ${name} at ${url}..."
    for i in $(seq 1 "$max_wait"); do
        if curl -sf "$url" > /dev/null 2>&1; then
            ok "${name} is ready."
            return 0
        fi
        sleep 1
    done
    err "${name} did not become ready within ${max_wait}s"
    return 1
}

build_and_upload_pypi_package() {
    local pkg_dir="$1"
    local registry_url="$2"
    local pkg_name

    pkg_name=$(basename "$pkg_dir")
    log "  Building ${pkg_name}..."

    cd "$pkg_dir"
    rm -rf dist/ 2>/dev/null
    python setup.py sdist -q

    # Upload using legacy PyPI upload protocol (requires :action field)
    for dist_file in dist/*; do
        if ! curl -sf -X POST "${registry_url}" \
            -F ":action=file_upload" \
            -F "content=@${dist_file}" \
            > /dev/null 2>&1; then
            warn "  Failed to upload $(basename "$dist_file") to ${registry_url}"
        fi
    done

    ok "  ${pkg_name} uploaded"
}

# ============================================================
# Tier flags (from Helm values via env vars)
# Default to "true" if not set (backward-compatible)
# ============================================================

TIER0="${TIER0_ENABLED:-true}"
TIER1="${TIER1_ENABLED:-true}"
TIER2="${TIER2_ENABLED:-true}"
TIER3="${TIER3_ENABLED:-true}"
TIER4="${TIER4_ENABLED:-true}"
TIER5="${TIER5_ENABLED:-true}"
TIER6="${TIER6_ENABLED:-true}"
TIER7="${TIER7_ENABLED:-true}"
TIER8="${TIER8_ENABLED:-true}"
TIER9="${TIER9_ENABLED:-true}"

tier_enabled() {
    local tier_var="TIER${1}"
    [[ "${!tier_var}" == "true" ]]
}

# ============================================================
# PHASE 1: Wait for all services
# ============================================================

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  WeakLink Labs — Setup${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""

echo -e "  Enabled tiers: $(for t in 0 1 2 3 4 5 6 7 8 9; do tier_enabled $t && printf "$t "; done)"
echo ""

wait_for_service "PyPI Private" "http://pypi-private:8080/simple/"
wait_for_service "PyPI Public"  "http://pypi-public:8080/simple/"
wait_for_service "Verdaccio"    "http://verdaccio:4873/-/ping"
wait_for_service "Gitea"        "http://gitea:3000/api/v1/version"
wait_for_service "OCI Registry" "http://registry:5000/v2/"

echo ""

# ============================================================
# PHASE 2: Seed PyPI Private (legitimate packages)
# ============================================================

echo -e "${BOLD}--- Seeding PyPI Private ---${NC}"

PYPI_PRIVATE_UPLOAD="http://pypi-private:8080/"
LABS="/labs"

# safe-utils 1.0.0 (from tier-0-foundations/0.2)
build_and_upload_pypi_package "${LABS}/tier-0-foundations/0.2-package-managers/src/packages/safe-utils" "$PYPI_PRIVATE_UPLOAD"

# internal-utils 1.0.0 (from tier-1/1.1)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.1-dependency-resolution/src/packages/internal-utils-1.0.0" "$PYPI_PRIVATE_UPLOAD"

# logging-helper 1.0.0 (from tier-1/1.1)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.1-dependency-resolution/src/packages/logging-helper-1.0.0" "$PYPI_PRIVATE_UPLOAD"

# data-processor 2.0.0 (from tier-1/1.1)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.1-dependency-resolution/src/packages/data-processor-2.0.0" "$PYPI_PRIVATE_UPLOAD"

# wl-auth 1.0.0 (from tier-1/1.2)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.2-dependency-confusion/src/packages/wl-auth-1.0.0" "$PYPI_PRIVATE_UPLOAD"

# flask-utils 1.0.0 (from tier-1/1.4)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils" "$PYPI_PRIVATE_UPLOAD"

# requests 2.31.0 simulated (from tier-1/1.3)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.3-typosquatting/src/packages/requests-legit" "$PYPI_PRIVATE_UPLOAD"

ok "PyPI Private seeded."
echo ""

# ============================================================
# PHASE 3: Seed PyPI Public (malicious packages)
# ============================================================

echo -e "${BOLD}--- Seeding PyPI Public ---${NC}"

PYPI_PUBLIC_UPLOAD="http://pypi-public:8080/"

# internal-utils 99.0.0 — dependency confusion (from tier-1/1.1)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.1-dependency-resolution/src/packages/internal-utils-99.0.0" "$PYPI_PUBLIC_UPLOAD"

# wl-auth 99.0.0, dependency confusion (from tier-1/1.2)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.2-dependency-confusion/src/packages/wl-auth-99.0.0" "$PYPI_PUBLIC_UPLOAD"

# malicious-utils 1.0.0 — malicious setup.py (from tier-0/0.2)
build_and_upload_pypi_package "${LABS}/tier-0-foundations/0.2-package-managers/src/packages/malicious-utils" "$PYPI_PUBLIC_UPLOAD"

# reqeusts 2.31.0 — typosquatted (from tier-1/1.3)
build_and_upload_pypi_package "${LABS}/tier-1-package-security/1.3-typosquatting/src/packages/reqeusts-typo" "$PYPI_PUBLIC_UPLOAD"

# flask-utils 1.0.1 — backdoored for lockfile injection (from tier-1/1.4)
# We create a version 1.0.1 from the backdoor source to enable lockfile attacks
BACKDOOR_TEMP=$(mktemp -d)
cp -r "${LABS}/tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils-backdoor/"* "$BACKDOOR_TEMP/"
# Patch version to 1.0.1 so it looks like a "patch update"
sed -i 's/version="1.0.0"/version="1.0.1"/' "$BACKDOOR_TEMP/setup.py"
sed -i 's/__version__ = "1.0.0"/__version__ = "1.0.1"/' "$BACKDOOR_TEMP/flask_utils/__init__.py" 2>/dev/null || true
build_and_upload_pypi_package "$BACKDOOR_TEMP" "$PYPI_PUBLIC_UPLOAD"
rm -rf "$BACKDOOR_TEMP"

ok "PyPI Public seeded."
echo ""

# ============================================================
# PHASE 4: Seed Verdaccio (npm packages)
# ============================================================

echo -e "${BOLD}--- Seeding Verdaccio ---${NC}"

VERDACCIO_URL="http://verdaccio:4873"

# Create auth token for publishing
log "Authenticating with Verdaccio..."
UNIQUE_USER="labuser-$(date +%s)"
TOKEN=$(curl -sf -X PUT "${VERDACCIO_URL}/-/user/org.couchdb.user:${UNIQUE_USER}" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"${UNIQUE_USER}\",\"password\":\"labpass123\"}" | jq -r '.token // empty')

if [[ -z "$TOKEN" ]]; then
    # Retry — verdaccio sometimes needs the user to exist first
    TOKEN=$(curl -sf -X PUT "${VERDACCIO_URL}/-/user/org.couchdb.user:${UNIQUE_USER}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${UNIQUE_USER}\",\"password\":\"labpass123\"}" | jq -r '.token // empty')
fi

if [[ -z "$TOKEN" ]]; then
    err "Failed to get Verdaccio auth token"
    exit 1
fi

echo "//verdaccio:4873/:_authToken=${TOKEN}" > ~/.npmrc
echo "registry=${VERDACCIO_URL}/" >> ~/.npmrc
ok "Verdaccio authenticated."

# Helper: publish an npm package from a directory
npm_publish() {
    local pkg_dir="$1"
    local pkg_name
    pkg_name=$(jq -r '.name' "$pkg_dir/package.json")
    local pkg_version
    pkg_version=$(jq -r '.version' "$pkg_dir/package.json")

    log "  Publishing ${pkg_name}@${pkg_version}..."
    cd "$pkg_dir"
    npm publish --registry "$VERDACCIO_URL" 2>&1 | tail -1 || true
    ok "  ${pkg_name}@${pkg_version} published"
}

# Publish lodash stub (dependency for many packages)
log "Creating lodash stub..."
LODASH_DIR=$(mktemp -d)/lodash
mkdir -p "$LODASH_DIR"
cat > "$LODASH_DIR/package.json" << 'EOF'
{
  "name": "lodash",
  "version": "4.17.21",
  "description": "Lodash stub for lab",
  "main": "index.js"
}
EOF
cat > "$LODASH_DIR/index.js" << 'EOF'
module.exports = {
  capitalize: (s) => s ? s.charAt(0).toUpperCase() + s.slice(1) : '',
  isEmpty: (v) => !v || (typeof v === 'object' && Object.keys(v).length === 0),
  sortBy: (arr) => [...arr].sort((a, b) => a - b),
  uniq: (arr) => [...new Set(arr)],
  chunk: (arr, size) => { const r = []; for (let i = 0; i < arr.length; i += size) r.push(arr.slice(i, i + size)); return r; }
};
EOF
npm_publish "$LODASH_DIR"

# safe-utils@1.0.0 (from tier-1/1.5)
npm_publish "${LABS}/tier-1-package-security/1.5-manifest-confusion/src/packages/safe-utils"

# evil-pkg@1.0.0 (from tier-1/1.5)
npm_publish "${LABS}/tier-1-package-security/1.5-manifest-confusion/src/packages/evil-pkg"

# crafted-widget@2.1.0 with manifest confusion (from tier-1/1.5)
log "  Publishing crafted-widget with manifest confusion..."
cd "${LABS}/tier-1-package-security/1.5-manifest-confusion/src/packages/crafted-widget"
npm pack 2>&1 > /dev/null
TARBALL=$(ls crafted-widget-*.tgz 2>/dev/null | head -1)

if [[ -n "$TARBALL" ]]; then
    # Craft the publish request with mismatched metadata
    node -e "
const fs = require('fs');
const crypto = require('crypto');
const http = require('http');

const tarball = fs.readFileSync('${TARBALL}');
const tarballBase64 = tarball.toString('base64');
const shasum = crypto.createHash('sha1').update(tarball).digest('hex');
const integrity = 'sha512-' + crypto.createHash('sha512').update(tarball).digest('base64');

const fakeManifest = {
    name: 'crafted-widget',
    version: '2.1.0',
    description: 'A helpful widget library',
    main: 'index.js',
    dependencies: { 'lodash': '^4.17.21' },
    scripts: {}
};

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
                tarball: '${VERDACCIO_URL}/crafted-widget/-/crafted-widget-2.1.0.tgz'
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

const data = JSON.stringify(payload);
const req = http.request({
    hostname: 'verdaccio',
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
            console.log('[+] crafted-widget published with manifest confusion');
        } else {
            console.log('[-] crafted-widget publish failed:', res.statusCode, body);
        }
    });
});
req.write(data);
req.end();
"
    rm -f "$TARBALL"
    sleep 1
else
    warn "  Could not pack crafted-widget, skipping manifest confusion"
fi
ok "  crafted-widget published"

# wl-framework@1.0.0 (from tier-1/1.6)
npm_publish "${LABS}/tier-1-package-security/1.6-phantom-dependencies/src/packages/wl-framework/v1"

# wl-framework@2.0.0 (from tier-1/1.6)
npm_publish "${LABS}/tier-1-package-security/1.6-phantom-dependencies/src/packages/wl-framework/v2"

# debug@4.3.4 — legitimate debug stub
log "Creating debug@4.3.4 (legitimate)..."
DEBUG_DIR=$(mktemp -d)/debug
mkdir -p "$DEBUG_DIR"
cat > "$DEBUG_DIR/package.json" << 'EOF'
{
  "name": "debug",
  "version": "4.3.4",
  "description": "Lightweight debugging utility",
  "main": "index.js"
}
EOF
cat > "$DEBUG_DIR/index.js" << 'EOF'
module.exports = function createDebug(namespace) {
  const fn = function(...args) {
    if (process.env.DEBUG) {
      console.log(`[${namespace}]`, ...args);
    }
  };
  fn.enabled = !!process.env.DEBUG;
  fn.namespace = namespace;
  return fn;
};
EOF
npm_publish "$DEBUG_DIR"

# debug@99.0.0 — malicious (from tier-1/1.6)
npm_publish "${LABS}/tier-1-package-security/1.6-phantom-dependencies/src/packages/debug-malicious"

ok "Verdaccio seeded."
echo ""

# ============================================================
# PHASE 5: Seed Gitea
# ============================================================

echo -e "${BOLD}--- Seeding Gitea ---${NC}"

GITEA_URL="http://gitea:3000"
GITEA_USER="weaklink"
GITEA_PASS="weaklink"
GITEA_EMAIL="admin@weaklink.local"

# Create admin user
# Gitea allows creating user via admin API if INSTALL_LOCK=true
# The first user created via the sign-up endpoint gets admin
log "Creating admin user..."
curl -sf -X POST "${GITEA_URL}/api/v1/user/signup" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"${GITEA_USER}\",
        \"password\": \"${GITEA_PASS}\",
        \"email\": \"${GITEA_EMAIL}\",
        \"full_name\": \"WeakLink Admin\"
    }" > /dev/null 2>&1 || {
    # Fallback to web registration
    curl -sf -X POST "${GITEA_URL}/user/sign_up" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "user_name=${GITEA_USER}&password=${GITEA_PASS}&retype=${GITEA_PASS}&email=${GITEA_EMAIL}" \
        -L > /dev/null 2>&1 || warn "  User may already exist"
}
ok "Admin user ready."

AUTH_URL="http://${GITEA_USER}:${GITEA_PASS}@gitea:3000"

# --- web-app repository (for lab 0.1) ---
log "Creating web-app repository..."
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
    -H "Content-Type: application/json" \
    -u "${GITEA_USER}:${GITEA_PASS}" \
    -d '{"name": "web-app", "auto_init": false, "private": false, "default_branch": "main"}' \
    > /dev/null 2>&1 || warn "  web-app repo may already exist"

WORKDIR=$(mktemp -d)
cd "$WORKDIR"
git init -q

# Commit 1: Initial project setup
mkdir -p src tests
cat > src/app.py << 'PYEOF'
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Welcome to the Web App!"

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYEOF

cat > requirements.txt << 'PYEOF'
flask==3.0.0
PYEOF

cat > build.sh << 'SHEOF'
#!/bin/bash
echo "=== Building Web App ==="
echo "Installing dependencies..."
pip install -r requirements.txt
echo "Running tests..."
python -m pytest tests/ || true
echo "Build complete!"
SHEOF
chmod +x build.sh

cat > README.md << 'MDEOF'
# Web App

A simple Flask web application.

## Build

```bash
./build.sh
```

## Run

```bash
python src/app.py
```
MDEOF

git add .
git commit -q -m "Initial project setup

Added Flask app with health endpoint, build script, and requirements."

# Commit 2: Add tests
cat > tests/__init__.py << 'PYEOF'
PYEOF
cat > tests/test_app.py << 'PYEOF'
def test_placeholder():
    """Placeholder test"""
    assert True
PYEOF

git add .
git commit -q -m "Add test framework

Added pytest test directory with a placeholder test."

# Commit 3: Add configuration
cat > config.yml << 'YMLEOF'
app:
  name: "web-app"
  version: "1.0.0"
  debug: false
  port: 5000

database:
  host: "localhost"
  port: 5432
  name: "webapp_db"
YMLEOF

git add .
git commit -q -m "Add application configuration

Added config.yml with app and database settings."

# Commit 4: Update app with config loading
cat > src/app.py << 'PYEOF'
import os
import yaml
from flask import Flask, jsonify

app = Flask(__name__)

def load_config():
    config_path = os.path.join(os.path.dirname(__file__), "..", "config.yml")
    with open(config_path) as f:
        return yaml.safe_load(f)

@app.route("/")
def home():
    return "Welcome to the Web App v1.0!"

@app.route("/health")
def health():
    return jsonify({"status": "ok", "version": "1.0.0"})

@app.route("/info")
def info():
    config = load_config()
    return jsonify({
        "app": config["app"]["name"],
        "version": config["app"]["version"]
    })

if __name__ == "__main__":
    config = load_config()
    app.run(
        host="0.0.0.0",
        port=config["app"]["port"],
        debug=config["app"]["debug"]
    )
PYEOF

cat > requirements.txt << 'PYEOF'
flask==3.0.0
pyyaml==6.0.1
PYEOF

git add .
git commit -q -m "Load config from YAML file

Updated app to read settings from config.yml. Added pyyaml dependency.
Added /info endpoint to expose app metadata."

# Feature branch
git checkout -q -b feature/add-logging
cat > src/logger.py << 'PYEOF'
import logging
import sys

def setup_logging(level="INFO"):
    logger = logging.getLogger("webapp")
    logger.setLevel(getattr(logging, level))
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(
        logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    )
    logger.addHandler(handler)
    return logger
PYEOF

git add .
git commit -q -m "Add logging module

Added centralized logging setup for the application."

git checkout -q main

# Push both branches
git remote add origin "${GITEA_URL}/${GITEA_USER}/web-app.git"
git push -q -u "${AUTH_URL}/${GITEA_USER}/web-app.git" main 2>/dev/null || true
git push -q "${AUTH_URL}/${GITEA_USER}/web-app.git" feature/add-logging 2>/dev/null || true

ok "web-app repository created (4 commits on main + feature branch)."

# Clean up
cd /
rm -rf "$WORKDIR"

# --- secure-app repository (for lab 1.4 — lockfile injection PR) ---
log "Creating secure-app repository..."
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
    -H "Content-Type: application/json" \
    -u "${GITEA_USER}:${GITEA_PASS}" \
    -d '{"name": "secure-app", "auto_init": false, "private": false, "default_branch": "main"}' \
    > /dev/null 2>&1 || warn "  secure-app repo may already exist"

WORKDIR=$(mktemp -d)
cd "$WORKDIR"
git init -q

# requirements.in
cat > requirements.in << 'EOF'
# Project dependencies
flask-utils
EOF

# app.py
cat > app.py << 'EOF'
"""Sample app using flask-utils."""
from flask_utils import json_response, validate_request

request_data = {"name": "Lab User", "email": "user@lab.local"}
valid, error = validate_request(["name", "email"], request_data)

if valid:
    response = json_response({"message": "User created", "user": request_data})
    print(f"[+] Success: {response}")
else:
    print(f"[-] Validation error: {error}")
EOF

# Generate a legitimate lockfile
# We build the flask-utils wheel and calculate its hash
FLASK_UTILS_DIR="${LABS}/tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils"
TMPWHEEL=$(mktemp -d)
cd "$TMPWHEEL"
pip wheel --no-deps -w . "$FLASK_UTILS_DIR" -q 2>/dev/null
LEGIT_WHEEL=$(ls flask_utils-*.whl 2>/dev/null | head -1)
LEGIT_HASH=""
if [[ -n "$LEGIT_WHEEL" ]]; then
    LEGIT_HASH=$(python3 -c "
import hashlib
with open('${LEGIT_WHEEL}', 'rb') as f:
    print(hashlib.sha256(f.read()).hexdigest())
")
fi
cd "$WORKDIR"
rm -rf "$TMPWHEEL"

# Create a plausible lockfile
cat > requirements.txt << EOF
#
# This file is autogenerated by pip-compile with Python 3.11
#
flask-utils==1.0.0 \\
    --hash=sha256:${LEGIT_HASH:-0000000000000000000000000000000000000000000000000000000000000000}
EOF

# Verify lockfile script
cat > verify-lockfile.sh << 'SHEOF'
#!/bin/bash
# CI Check: Verify lockfile integrity
set -uo pipefail
REQ_IN="${1:-requirements.in}"
REQ_TXT="${2:-requirements.txt}"
echo "[*] Regenerating lockfile from ${REQ_IN}..."
TMPFILE=$(mktemp)
pip-compile --generate-hashes \
    --index-url http://pypi-private:8080/simple/ \
    --trusted-host pypi-private \
    --quiet \
    "$REQ_IN" \
    --output-file "$TMPFILE" 2>/dev/null
DIFF=$(diff <(grep -v "^#" "$REQ_TXT" | grep -v "^$") <(grep -v "^#" "$TMPFILE" | grep -v "^$"))
rm -f "$TMPFILE"
if [[ -z "$DIFF" ]]; then
    echo "[+] Lockfile is consistent. No tampering detected."
    exit 0
else
    echo "[-] LOCKFILE MISMATCH DETECTED!"
    echo "$DIFF" | sed 's/^/    /'
    exit 1
fi
SHEOF
chmod +x verify-lockfile.sh

git add -A
git commit -q -m "Initial commit: secure-app with flask-utils dependency"

# Push main
git remote add origin "${GITEA_URL}/${GITEA_USER}/secure-app.git"
git push -q -u "${AUTH_URL}/${GITEA_USER}/secure-app.git" main 2>/dev/null || true

# Create malicious PR branch
git checkout -q -b update-deps

# Build the backdoored flask-utils wheel and get its hash
BACKDOOR_DIR="${LABS}/tier-1-package-security/1.4-lockfile-injection/src/packages/flask-utils-backdoor"
TMPWHEEL=$(mktemp -d)
cd "$TMPWHEEL"
pip wheel --no-deps -w . "$BACKDOOR_DIR" -q 2>/dev/null
BACKDOOR_WHEEL=$(ls flask_utils-*.whl 2>/dev/null | head -1)
BACKDOOR_HASH=""
if [[ -n "$BACKDOOR_WHEEL" ]]; then
    BACKDOOR_HASH=$(python3 -c "
import hashlib
with open('${BACKDOOR_WHEEL}', 'rb') as f:
    print(hashlib.sha256(f.read()).hexdigest())
")
fi
cd "$WORKDIR"
rm -rf "$TMPWHEEL"

# Replace the hash in the lockfile
if [[ -n "$BACKDOOR_HASH" ]]; then
    sed -i "s/--hash=sha256:[a-f0-9]*/--hash=sha256:${BACKDOOR_HASH}/" requirements.txt
else
    sed -i 's/--hash=sha256:[a-f0-9]*/--hash=sha256:deadbeef00000000000000000000000000000000000000000000000000000000/' requirements.txt
fi

git add requirements.txt
git commit -q -m "chore: update flask-utils to latest version

Routine dependency update. Ran pip-compile to refresh the lockfile."

git push -q "${AUTH_URL}/${GITEA_USER}/secure-app.git" update-deps 2>/dev/null || true

# Create PR
curl -sf -X POST "${GITEA_URL}/api/v1/repos/${GITEA_USER}/secure-app/pulls" \
    -H "Content-Type: application/json" \
    -u "${GITEA_USER}:${GITEA_PASS}" \
    -d '{
        "title": "chore: update flask-utils to latest version",
        "body": "Routine dependency update.\n\nRan `pip-compile` to refresh the lockfile. No functional changes.\n\n---\n_Auto-generated by dependabot-like bot_",
        "head": "update-deps",
        "base": "main"
    }' > /dev/null 2>&1 || warn "  PR creation may have failed"

ok "secure-app repository created with malicious PR."

cd /
rm -rf "$WORKDIR"

ok "Gitea seeded."
echo ""

# ============================================================
# PHASE 6: Seed OCI Registry
# ============================================================

echo -e "${BOLD}--- Seeding OCI Registry ---${NC}"

# We can't run docker build inside this container without docker-in-docker.
# Instead, we create minimal OCI images using curl and the registry API.
# For the lab, we use a simple approach: push layer blobs manually.

REGISTRY_URL="http://registry:5000"

# Helper function to create and push a minimal OCI image
push_oci_image() {
    local name="$1"
    local tag="$2"
    local content="$3"

    log "  Pushing ${name}:${tag}..."

    # Create a simple layer (just a tar with a marker file)
    local tmpdir
    tmpdir=$(mktemp -d)
    echo "$content" > "${tmpdir}/marker.txt"
    tar -czf "${tmpdir}/layer.tar.gz" -C "$tmpdir" marker.txt

    local layer_digest
    layer_digest=$(sha256sum "${tmpdir}/layer.tar.gz" | cut -d' ' -f1)
    local layer_size
    layer_size=$(stat -c%s "${tmpdir}/layer.tar.gz" 2>/dev/null || stat -f%z "${tmpdir}/layer.tar.gz")

    # Start upload
    local upload_url
    upload_url=$(curl -sf -X POST "${REGISTRY_URL}/v2/${name}/blobs/uploads/" \
        -D - -o /dev/null 2>&1 | grep -i "location:" | tr -d '\r' | awk '{print $2}')

    if [[ -n "$upload_url" ]]; then
        # Upload the layer blob
        # Handle relative URLs
        if [[ "$upload_url" == /* ]]; then
            upload_url="${REGISTRY_URL}${upload_url}"
        fi
        curl -sf -X PUT "${upload_url}&digest=sha256:${layer_digest}" \
            -H "Content-Type: application/octet-stream" \
            --data-binary "@${tmpdir}/layer.tar.gz" > /dev/null 2>&1

        # Create and push config blob
        local config='{"architecture":"amd64","os":"linux","config":{}}'
        echo -n "$config" > "${tmpdir}/config.json"
        local config_digest
        config_digest=$(echo -n "$config" | sha256sum | cut -d' ' -f1)
        local config_size
        config_size=$(echo -n "$config" | wc -c | tr -d ' ')

        local config_upload_url
        config_upload_url=$(curl -sf -X POST "${REGISTRY_URL}/v2/${name}/blobs/uploads/" \
            -D - -o /dev/null 2>&1 | grep -i "location:" | tr -d '\r' | awk '{print $2}')
        if [[ "$config_upload_url" == /* ]]; then
            config_upload_url="${REGISTRY_URL}${config_upload_url}"
        fi
        curl -sf -X PUT "${config_upload_url}&digest=sha256:${config_digest}" \
            -H "Content-Type: application/octet-stream" \
            --data-binary "@${tmpdir}/config.json" > /dev/null 2>&1

        # Create and push manifest
        local manifest
        manifest=$(cat << MEOF
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
  "config": {
    "mediaType": "application/vnd.docker.container.image.v1+json",
    "size": ${config_size},
    "digest": "sha256:${config_digest}"
  },
  "layers": [
    {
      "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip",
      "size": ${layer_size},
      "digest": "sha256:${layer_digest}"
    }
  ]
}
MEOF
)
        curl -sf -X PUT "${REGISTRY_URL}/v2/${name}/manifests/${tag}" \
            -H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" \
            -d "$manifest" > /dev/null 2>&1

        ok "  ${name}:${tag} pushed"
    else
        warn "  Failed to initiate upload for ${name}:${tag}"
    fi

    rm -rf "$tmpdir"
}

# Push safe webapp:latest (this represents the initial good state)
push_oci_image "webapp" "1.0.0" "safe-image: webapp v1.0.0 -- no backdoor"
push_oci_image "webapp" "latest" "safe-image: webapp v1.0.0 -- no backdoor"

# Push backdoored webapp:latest (overwrites the latest tag -- tag poisoning)
push_oci_image "webapp" "latest" "BACKDOORED: This image contains a backdoor! Environment variables have been exfiltrated."

ok "OCI Registry seeded (webapp:latest is now backdoored -- tag poisoning)."
echo ""

# ============================================================
# DONE
# ============================================================

echo -e "${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}  WeakLink Labs setup complete!${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo -e "  PyPI Private: 7 legitimate packages"
echo -e "  PyPI Public:  5 malicious packages"
echo -e "  Verdaccio:    7+ npm packages (incl. manifest confusion)"
echo -e "  Gitea:        2 repos (web-app, secure-app with malicious PR)"
echo -e "  OCI Registry: webapp:latest (backdoored via tag poisoning)"
echo ""

exit 0

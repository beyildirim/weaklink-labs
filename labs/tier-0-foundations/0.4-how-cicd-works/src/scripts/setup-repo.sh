#!/bin/bash
set -euo pipefail
GITEA_URL="http://gitea:3000"
ADMIN_USER="weaklink"
ADMIN_PASS="weaklink"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_SRC="${SCRIPT_DIR}/../repo"

echo "[*] Resetting ci-demo repository..."
curl -sf -X DELETE "${GITEA_URL}/api/v1/repos/${ADMIN_USER}/ci-demo" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" > /dev/null 2>&1 || true

echo "[*] Creating ci-demo repository..."
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" \
    -H "Content-Type: application/json" \
    -d '{"name":"ci-demo","auto_init":true,"default_branch":"main"}'

echo "[*] Pushing CI workflow and source files..."
cd /tmp && rm -rf ci-demo
git clone "http://${ADMIN_USER}:${ADMIN_PASS}@gitea:3000/${ADMIN_USER}/ci-demo.git"
cd ci-demo
cp -r "${REPO_SRC}/"* .
cp -r "${REPO_SRC}/.gitea" .
git add -A && git commit -m "Initial CI pipeline setup" && git push
echo "[+] ci-demo repository ready."

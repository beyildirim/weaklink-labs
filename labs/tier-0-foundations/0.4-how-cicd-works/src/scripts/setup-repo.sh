#!/bin/bash
set -euo pipefail
GITEA_URL="http://gitea:3000"
ADMIN_USER="labadmin"
ADMIN_PASS="SupplyChainLab1!"

echo "[*] Creating ci-demo repository..."
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
    -u "${ADMIN_USER}:${ADMIN_PASS}" \
    -H "Content-Type: application/json" \
    -d '{"name":"ci-demo","auto_init":true,"default_branch":"main"}'

echo "[*] Pushing CI workflow and source files..."
cd /tmp && rm -rf ci-demo
git clone "http://${ADMIN_USER}:${ADMIN_PASS}@gitea:3000/${ADMIN_USER}/ci-demo.git"
cd ci-demo
cp -r /labs/tier-0-foundations/0.4-how-cicd-works/src/repo/* .
cp -r /labs/tier-0-foundations/0.4-how-cicd-works/src/repo/.gitea .
git add -A && git commit -m "Initial CI pipeline setup" && git push
echo "[+] ci-demo repository ready."

#!/bin/bash
# Setup script: initializes the Gitea repo with the vulnerable CI config for PPE
set -euo pipefail

GITEA_URL="http://gitea:3000"
REPO_NAME="wl-webapp"
REPO_DIR="/repos/${REPO_NAME}"

echo "[setup] Creating Gitea repo: ${REPO_NAME}"
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": false}" || true

mkdir -p "${REPO_DIR}"
cd "${REPO_DIR}"
git init
git checkout -b main

cp /lab/src/repo/app.py .
cp /lab/src/repo/requirements.txt .
cp /lab/src/repo/test_app.py .
mkdir -p .gitea/workflows
cp /lab/src/repo/.gitea/workflows/ci.yml .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: webapp with CI pipeline"
git remote add origin "${GITEA_URL}/weaklink/${REPO_NAME}.git"
git push -u origin main

# Set secrets
curl -sf -X PUT "${GITEA_URL}/api/v1/repos/weaklink/${REPO_NAME}/actions/secrets/DEPLOY_TOKEN" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d '{"data": "ghp_deploy_x8k2m5n7p9q1r3t6v0w4y"}'

# Create attacker account
curl -sf -X POST "${GITEA_URL}/api/v1/admin/users" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d '{"username":"attacker","password":"password","email":"attacker@evil.com","must_change_password":false}' || true

echo "[setup] Lab 2.2 ready."

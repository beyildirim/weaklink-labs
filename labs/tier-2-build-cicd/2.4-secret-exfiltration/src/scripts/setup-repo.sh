#!/bin/bash
set -euo pipefail

GITEA_URL="http://gitea:3000"
REPO_NAME="wl-webapp"
REPO_DIR="/repos/${REPO_NAME}"

echo "[setup] Creating Gitea repo: ${REPO_NAME}"
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": false}" || true

mkdir -p "${REPO_DIR}" && cd "${REPO_DIR}"
git init && git checkout -b main

cp /lab/src/repo/app.py .
cp /lab/src/repo/requirements.txt .
cp /lab/src/repo/test_app.py .
mkdir -p .gitea/workflows
cp /lab/src/repo/.gitea/workflows/ci.yml .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: webapp with overly-permissive CI secrets"
git remote add origin "${GITEA_URL}/weaklink/${REPO_NAME}.git"
git push -u origin main

for secret in DEPLOY_TOKEN DB_PASSWORD API_KEY; do
  curl -sf -X PUT "${GITEA_URL}/api/v1/repos/weaklink/${REPO_NAME}/actions/secrets/${secret}" \
    -H "Content-Type: application/json" \
    -u "weaklink:weaklink" \
    -d "{\"data\": \"secret-${secret,,}-7f3a9b2c4d\"}"
done

echo "[setup] Lab 2.4 ready."

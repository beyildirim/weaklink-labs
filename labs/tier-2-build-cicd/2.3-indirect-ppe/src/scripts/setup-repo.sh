#!/bin/bash
set -euo pipefail

GITEA_URL="http://gitea:3000"
REPO_NAME="wl-webapp"
REPO_DIR="/repos/${REPO_NAME}"

echo "[setup] Creating Gitea repo: ${REPO_NAME}"
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -u "developer:password" \
  -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": false}" || true

mkdir -p "${REPO_DIR}"
cd "${REPO_DIR}"
git init && git checkout -b main

cp /lab/src/repo/app.py .
cp /lab/src/repo/requirements.txt .
cp /lab/src/repo/test_app.py .
cp /lab/src/repo/Makefile .
mkdir -p scripts
cp /lab/src/repo/scripts/run-tests.sh scripts/
chmod +x scripts/run-tests.sh
mkdir -p .gitea/workflows
cp /lab/src/repo/.gitea/workflows/ci.yml .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: webapp with Makefile-based CI"
git remote add origin "${GITEA_URL}/developer/${REPO_NAME}.git"
git push -u origin main

curl -sf -X PUT "${GITEA_URL}/api/v1/repos/developer/${REPO_NAME}/actions/secrets/DEPLOY_TOKEN" \
  -H "Content-Type: application/json" \
  -u "developer:password" \
  -d '{"data": "ghp_deploy_x8k2m5n7p9q1r3t6v0w4y"}'

echo "[setup] Lab 2.3 ready."

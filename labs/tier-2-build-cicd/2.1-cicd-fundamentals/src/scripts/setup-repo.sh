#!/bin/bash
# Setup script: initializes the Gitea repo with the vulnerable CI config
set -euo pipefail

GITEA_URL="http://gitea:3000"
REPO_NAME="acme-webapp"
REPO_DIR="/repos/${REPO_NAME}"

echo "[setup] Creating Gitea repo: ${REPO_NAME}"
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -u "developer:password" \
  -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": false}" || true

echo "[setup] Initializing local repo"
mkdir -p "${REPO_DIR}"
cd "${REPO_DIR}"
git init
git checkout -b main

# Copy source files
cp /lab/src/repo/app.py .
cp /lab/src/repo/requirements.txt .
cp /lab/src/repo/test_app.py .
mkdir -p .gitea/workflows
cp /lab/src/repo/.gitea/workflows/ci.yml .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: ACME webapp with CI pipeline"

git remote add origin "${GITEA_URL}/developer/${REPO_NAME}.git"
git push -u origin main

# Set repository secrets
curl -sf -X PUT "${GITEA_URL}/api/v1/repos/developer/${REPO_NAME}/actions/secrets/SECRET_TOKEN" \
  -H "Content-Type: application/json" \
  -u "developer:password" \
  -d '{"data": "sk-acme-prod-7f3a9b2c4d5e6f1a"}'

curl -sf -X PUT "${GITEA_URL}/api/v1/repos/developer/${REPO_NAME}/actions/secrets/DEPLOY_TOKEN" \
  -H "Content-Type: application/json" \
  -u "developer:password" \
  -d '{"data": "ghp_deploy_x8k2m5n7p9q1r3t6v0w4y"}'

curl -sf -X PUT "${GITEA_URL}/api/v1/repos/developer/${REPO_NAME}/actions/secrets/AWS_ACCESS_KEY_ID" \
  -H "Content-Type: application/json" \
  -u "developer:password" \
  -d '{"data": "AKIAIOSFODNN7EXAMPLE"}'

echo "[setup] Lab 2.1 ready. Repo: ${GITEA_URL}/developer/${REPO_NAME}"

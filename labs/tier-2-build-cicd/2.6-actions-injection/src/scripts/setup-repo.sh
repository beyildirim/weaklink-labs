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
mkdir -p .gitea/workflows
cp /lab/src/repo/.gitea/workflows/issue-handler.yml .gitea/workflows/issue-handler.yml
cp /lab/src/repo/.gitea/workflows/pr-handler.yml .gitea/workflows/pr-handler.yml

git add -A
git commit -m "Initial commit: webapp with issue/PR automation"
git remote add origin "${GITEA_URL}/weaklink/${REPO_NAME}.git"
git push -u origin main

# Create attacker account used to open issues in the guide steps
curl -sf -X POST "${GITEA_URL}/api/v1/admin/users" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d '{"username":"attacker","password":"password","email":"attacker@evil.com","must_change_password":false}' || true

curl -sf -X PUT "${GITEA_URL}/api/v1/repos/weaklink/${REPO_NAME}/actions/secrets/SLACK_WEBHOOK" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d '{"data": "https://hooks.slack.com/services/T00/B00/xxxx"}'

echo "[setup] Lab 2.6 ready."

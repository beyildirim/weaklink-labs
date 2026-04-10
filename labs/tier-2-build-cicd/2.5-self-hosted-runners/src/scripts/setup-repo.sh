#!/bin/bash
set -euo pipefail

GITEA_URL="http://gitea:3000"
REPO_NAME="wl-webapp"
REPO_DIR="/repos/${REPO_NAME}"
LAB_ROOT="/home/labs/2.5"

echo "[setup] Creating Gitea repo: ${REPO_NAME}"
curl -sf -X DELETE "${GITEA_URL}/api/v1/repos/weaklink/${REPO_NAME}" \
  -u "weaklink:weaklink" >/dev/null 2>&1 || true

curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": false}" || true

mkdir -p "${REPO_DIR}" && cd "${REPO_DIR}"
rm -rf "${REPO_DIR}/.git"
git init
git checkout -B main

cp "${LAB_ROOT}/repo/app.py" .
mkdir -p .gitea/workflows
cp "${LAB_ROOT}/repo/.gitea/workflows/ci.yml" .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: webapp with self-hosted runner CI"
git remote remove origin >/dev/null 2>&1 || true
git remote add origin "${GITEA_URL}/weaklink/${REPO_NAME}.git"
git push -u -f origin main

# Create attacker account used in the guide steps
curl -sf -X POST "${GITEA_URL}/api/v1/admin/users" \
  -H "Content-Type: application/json" \
  -u "weaklink:weaklink" \
  -d '{"username":"attacker","password":"password","email":"attacker@evil.com","must_change_password":false}' || true

# Set up the simulated runner
bash "${LAB_ROOT}/scripts/simulate-runner.sh"

echo "[setup] Lab 2.5 ready."

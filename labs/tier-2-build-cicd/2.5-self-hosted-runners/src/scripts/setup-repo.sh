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

mkdir -p "${REPO_DIR}" && cd "${REPO_DIR}"
git init && git checkout -b main

cp /lab/src/repo/app.py .
mkdir -p .gitea/workflows
cp /lab/src/repo/.gitea/workflows/ci.yml .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: webapp with self-hosted runner CI"
git remote add origin "${GITEA_URL}/developer/${REPO_NAME}.git"
git push -u origin main

# Set up the simulated runner
bash /lab/src/scripts/simulate-runner.sh

echo "[setup] Lab 2.5 ready."

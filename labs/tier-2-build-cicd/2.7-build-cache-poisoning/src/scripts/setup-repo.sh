#!/bin/bash
set -euo pipefail

GITEA_URL="http://gitea:3000"
REPO_NAME="wl-webapp"
REPO_DIR="/repos/${REPO_NAME}"
CACHE_DIR="/cache/pip"

echo "[setup] Creating Gitea repo: ${REPO_NAME}"
curl -sf -X POST "${GITEA_URL}/api/v1/user/repos" \
  -H "Content-Type: application/json" \
  -u "developer:password" \
  -d "{\"name\": \"${REPO_NAME}\", \"auto_init\": false}" || true

mkdir -p "${REPO_DIR}" && cd "${REPO_DIR}"
git init && git checkout -b main

cp /lab/src/repo/app.py .
cp /lab/src/repo/test_app.py .
cp /lab/src/repo/requirements.txt .
mkdir -p .gitea/workflows
cp /lab/src/repo/.gitea/workflows/ci.yml .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: webapp with cached CI pipeline"
git remote add origin "${GITEA_URL}/developer/${REPO_NAME}.git"
git push -u origin main

# Pre-populate the cache with legitimate packages
mkdir -p "${CACHE_DIR}"
pip download flask==3.0.0 requests==2.31.0 -d "${CACHE_DIR}" 2>/dev/null || true

echo "[setup] Lab 2.7 ready. Cache at ${CACHE_DIR}"

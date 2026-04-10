#!/bin/bash
set -euo pipefail

GITEA_URL="http://gitea:3000"
REPO_NAME="wl-webapp"
REPO_DIR="/repos/${REPO_NAME}"
CACHE_DIR="${HOME}/.cache/pip/wheels"
LAB_ROOT="/home/labs/2.7"

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
cp "${LAB_ROOT}/repo/test_app.py" .
cp "${LAB_ROOT}/repo/requirements.txt" .
mkdir -p .gitea/workflows
cp "${LAB_ROOT}/repo/.gitea/workflows/ci.yml" .gitea/workflows/ci.yml

git add -A
git commit -m "Initial commit: webapp with cached CI pipeline"
git remote remove origin >/dev/null 2>&1 || true
git remote add origin "${GITEA_URL}/weaklink/${REPO_NAME}.git"
git push -u -f origin main

# Pre-populate the cache with legitimate packages in the same location
# the workflow restores.
mkdir -p "${CACHE_DIR}"
pip download flask==3.0.0 requests==2.31.0 -d "${CACHE_DIR}" 2>/dev/null || true

echo "[setup] Lab 2.7 ready. Cache at ${CACHE_DIR}"

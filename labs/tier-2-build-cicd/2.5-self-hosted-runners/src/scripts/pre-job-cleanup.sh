#!/bin/bash
# Pre-job cleanup hook for self-hosted runners.
# This script runs BEFORE each job to ensure clean state.
set -euo pipefail

WORKSPACE="/runner/workspace"
KNOWN_HASH_FILE="/runner/config/workspace-baseline.sha256"

echo "[pre-job] Cleaning runner workspace..."

# Remove any non-git files from workspace
if [ -d "${WORKSPACE}" ]; then
    cd "${WORKSPACE}"
    # Remove all dotfiles except .git
    find . -maxdepth 1 -name ".*" ! -name ".git" ! -name "." -exec rm -rf {} +
    # Remove any files not tracked by git
    git clean -fdx 2>/dev/null || true
fi

# Verify runner profile is clean
CLEAN_PROFILE="# Clean runner profile"
echo "${CLEAN_PROFILE}" > "${WORKSPACE}/.bashrc"

# Remove any temp files from previous builds
rm -f /tmp/runner-compromised /tmp/backdoor-* /tmp/exfil-*

# Verify no unexpected cron jobs
crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" && {
    echo "[pre-job] WARNING: Unexpected cron jobs found!"
    crontab -r
}

echo "[pre-job] Runner state verified clean."

#!/bin/bash
# Simulates a self-hosted runner environment for the lab
set -euo pipefail

RUNNER_DIR="/runner"

echo "[setup] Creating simulated self-hosted runner environment..."

mkdir -p "${RUNNER_DIR}/workspace"
mkdir -p "${RUNNER_DIR}/hooks"
mkdir -p "${RUNNER_DIR}/config"

# Create a .bashrc that gets sourced before each job
cat > "${RUNNER_DIR}/workspace/.bashrc" << 'PROFILE'
# Runner profile -- sourced before each job
export RUNNER_NAME="acme-runner-01"
export RUNNER_OS="Linux"
PROFILE

# Create a simulated job executor
cat > "${RUNNER_DIR}/run-job.sh" << 'RUNNER'
#!/bin/bash
# Simulated job executor
echo "[runner] Starting job on $(hostname)..."
echo "[runner] Sourcing workspace profile..."
source /runner/workspace/.bashrc
echo "[runner] Running pre-job hooks..."
for hook in /runner/hooks/pre-job*.sh; do
    [ -f "$hook" ] && bash "$hook"
done
echo "[runner] Executing job steps..."
cd /runner/workspace
"$@"
echo "[runner] Job complete."
RUNNER
chmod +x "${RUNNER_DIR}/run-job.sh"

echo "[setup] Runner environment ready at ${RUNNER_DIR}/"

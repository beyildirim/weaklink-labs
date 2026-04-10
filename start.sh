#!/usr/bin/env bash
#
# WeakLink Labs -- Start
# One command to bring up the entire supply chain security training platform.
# Idempotent: safe to re-run at any point.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="weaklink"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()     { echo -e "${CYAN}[*]${NC} $*"; }
ok()      { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
err()     { echo -e "${RED}[-]${NC} $*"; }
header()  { echo -e "\n${BOLD}$*${NC}"; }

cleanup_on_failure() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo ""
        err "Setup failed at step: ${CURRENT_STEP:-unknown}"
        err "Exit code: $exit_code"
        echo ""
        echo -e "  ${DIM}Debug commands:${NC}"
        echo -e "    kubectl get pods -n ${NAMESPACE}"
        echo -e "    kubectl describe pods -n ${NAMESPACE}"
        echo -e "    kubectl logs -n ${NAMESPACE} job/lab-setup"
        echo ""
        echo -e "  ${DIM}To retry: make start${NC}"
        echo -e "  ${DIM}To tear down: make stop${NC}"
    fi
}
trap cleanup_on_failure EXIT

CURRENT_STEP="prerequisites"

# ============================================================
# Step 1: Check prerequisites
# ============================================================

header "Checking prerequisites..."

MISSING=()
for cmd in docker minikube kubectl helm; do
    if command -v "$cmd" &> /dev/null; then
        ok "$cmd found: $(command -v "$cmd")"
    else
        MISSING+=("$cmd")
        err "$cmd not found"
    fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo ""
    err "Missing prerequisites: ${MISSING[*]}"
    echo -e "  Install them before running this script."
    case "$(uname -s)" in
        Darwin*)  echo -e "  ${DIM}brew install ${MISSING[*]}${NC}" ;;
        Linux*)   echo -e "  ${DIM}See: https://minikube.sigs.k8s.io/docs/start/${NC}" ;;
        MINGW*|MSYS*|CYGWIN*) echo -e "  ${DIM}Use WSL2 or install via chocolatey/winget${NC}" ;;
    esac
    exit 1
fi

# ============================================================
# Step 2: Start minikube if not running
# ============================================================

CURRENT_STEP="minikube"
header "Starting minikube..."

MINIKUBE_STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")

if [[ "$MINIKUBE_STATUS" == "Running" ]]; then
    ok "minikube is already running."
else
    log "Starting minikube with 4 CPUs and 4GB memory..."
    minikube start --cpus=4 --memory=4096 --driver=docker 2>&1 | sed 's/^/  /'
    ok "minikube started."
fi

# ============================================================
# Step 3: Configure docker to use minikube's daemon
# ============================================================

CURRENT_STEP="docker-env"
header "Configuring Docker environment..."

eval $(minikube docker-env)
ok "Docker now targets minikube's daemon."

# ============================================================
# Step 4: Build all local images (skip if unchanged)
# ============================================================

CURRENT_STEP="docker-build"
header "Building Docker images..."

build_image() {
    local name="$1"
    local dockerfile="$2"
    local context="$3"

    log "Building ${name}..."
    if docker build -t "${name}" -f "${dockerfile}" "${context}" 2>&1 | tail -1; then
        ok "${name} built."
    else
        err "Failed to build ${name}"
        return 1
    fi
}

build_image "weaklink-labs/guide:latest" \
    "${SCRIPT_DIR}/images/guide/Dockerfile" \
    "${SCRIPT_DIR}"

build_image "weaklink-labs/workstation:latest" \
    "${SCRIPT_DIR}/images/workstation/Dockerfile" \
    "${SCRIPT_DIR}"

build_image "weaklink-labs/lab-setup:latest" \
    "${SCRIPT_DIR}/images/lab-setup/Dockerfile" \
    "${SCRIPT_DIR}"

# ============================================================
# Step 5: Deploy via Helm (upgrade --install is idempotent)
# ============================================================

CURRENT_STEP="helm-deploy"
header "Deploying to Kubernetes..."

log "Running helm upgrade --install..."
helm upgrade --install weaklink-labs \
    "${SCRIPT_DIR}/helm/weaklink-labs" \
    -n "${NAMESPACE}" --create-namespace \
    --wait --timeout 5m \
    2>&1 | sed 's/^/  /'
ok "Helm release deployed."

# ============================================================
# Step 6: Wait for pods to be ready
# ============================================================

CURRENT_STEP="pod-readiness"
header "Waiting for pods to be ready..."

COMPONENTS=("pypi-private" "pypi-public" "verdaccio" "gitea" "registry" "guide" "workstation")

for component in "${COMPONENTS[@]}"; do
    log "Waiting for ${component}..."
    kubectl wait --for=condition=available \
        deployment/"$component" \
        -n "${NAMESPACE}" \
        --timeout=120s 2>/dev/null \
        && ok "${component} is ready." \
        || warn "${component} may not be ready yet."
done

# Wait for the lab-setup job
CURRENT_STEP="lab-setup"
log "Waiting for lab-setup job to complete..."
# The job is created by a Helm hook, so give it a moment to appear
sleep 5
if kubectl get job lab-setup -n "${NAMESPACE}" &>/dev/null; then
    kubectl wait --for=condition=complete \
        job/lab-setup \
        -n "${NAMESPACE}" \
        --timeout=300s 2>/dev/null \
        && ok "Lab setup complete." \
        || warn "Lab setup still running. Check logs: kubectl logs -n ${NAMESPACE} job/lab-setup"
else
    warn "Lab setup job not found yet. It will run shortly."
fi

# ============================================================
# Step 7: Start port-forward (kill existing first for idempotency)
# ============================================================

CURRENT_STEP="port-forward"

# Kill any existing port-forwards from a previous run
for pidfile in "${SCRIPT_DIR}/.weaklink-pf.pid" "${SCRIPT_DIR}/.weaklink-pf-ttyd.pid" "${SCRIPT_DIR}/.weaklink-pf-verify.pid" "${SCRIPT_DIR}/.weaklink-pf-gitea.pid"; do
    if [[ -f "$pidfile" ]]; then
        old_pid=$(cat "$pidfile" 2>/dev/null || true)
        if [[ -n "$old_pid" ]] && kill -0 "$old_pid" 2>/dev/null; then
            kill "$old_pid" 2>/dev/null || true
        fi
        rm -f "$pidfile"
    fi
done

log "Starting port-forward for guide (localhost:8000)..."
nohup kubectl port-forward -n "${NAMESPACE}" svc/guide 8000:8000 > "${SCRIPT_DIR}/.weaklink-pf-guide.log" 2>&1 &
GUIDE_PF_PID=$!
echo "$GUIDE_PF_PID" > "${SCRIPT_DIR}/.weaklink-pf.pid"
ok "Guide port-forward started (PID: $GUIDE_PF_PID)."

log "Starting port-forward for web terminal (localhost:7681)..."
nohup kubectl port-forward -n "${NAMESPACE}" svc/workstation 7681:7681 > "${SCRIPT_DIR}/.weaklink-pf-ttyd.log" 2>&1 &
TTYD_PF_PID=$!
echo "$TTYD_PF_PID" > "${SCRIPT_DIR}/.weaklink-pf-ttyd.pid"
ok "Web terminal port-forward started (PID: $TTYD_PF_PID)."

log "Starting port-forward for verify API (localhost:7682)..."
nohup kubectl port-forward -n "${NAMESPACE}" svc/workstation 7682:7682 > "${SCRIPT_DIR}/.weaklink-pf-verify.log" 2>&1 &
VERIFY_PF_PID=$!
echo "$VERIFY_PF_PID" > "${SCRIPT_DIR}/.weaklink-pf-verify.pid"
ok "Verify API port-forward started (PID: $VERIFY_PF_PID)."

log "Starting port-forward for Gitea (localhost:3000)..."
nohup kubectl port-forward -n "${NAMESPACE}" svc/gitea 3000:3000 > "${SCRIPT_DIR}/.weaklink-pf-gitea.log" 2>&1 &
GITEA_PF_PID=$!
echo "$GITEA_PF_PID" > "${SCRIPT_DIR}/.weaklink-pf-gitea.pid"
ok "Gitea port-forward started (PID: $GITEA_PF_PID)."

CURRENT_STEP="done"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}  WeakLink Labs is ready!${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo -e "  Guide:       ${CYAN}http://localhost:8000${NC}"
echo -e "  Terminal:    ${CYAN}Use the split terminal inside the guide${NC}"
echo -e "  Gitea:       ${CYAN}http://localhost:3000${NC}"
echo ""
echo -e "  ${DIM}Useful commands:${NC}"
echo -e "    ${BOLD}make stop${NC}               Tear everything down"
echo -e "    ${BOLD}make status${NC}             Show pod status"
echo -e "    ${BOLD}make shell${NC}              Open a workstation shell"
echo ""

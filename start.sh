#!/usr/bin/env bash
#
# WeakLink Labs -- Start
# One command to bring up the entire supply chain security training platform.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

header "Configuring Docker environment..."

eval $(minikube docker-env)
ok "Docker now targets minikube's daemon."

# ============================================================
# Step 4: Build all local images
# ============================================================

header "Building Docker images..."

log "Building weaklink-labs/guide:latest..."
if [[ -f "${SCRIPT_DIR}/images/guide/Dockerfile" ]]; then
    docker build -t weaklink-labs/guide:latest \
        -f "${SCRIPT_DIR}/images/guide/Dockerfile" \
        "${SCRIPT_DIR}" 2>&1 | tail -1
    ok "weaklink-labs/guide:latest built."
else
    warn "Guide Dockerfile not found, skipping."
fi

log "Building weaklink-labs/workstation:latest..."
docker build -t weaklink-labs/workstation:latest \
    -f "${SCRIPT_DIR}/images/workstation/Dockerfile" \
    "${SCRIPT_DIR}/images/workstation" 2>&1 | tail -1
ok "weaklink-labs/workstation:latest built."

log "Building weaklink-labs/lab-setup:latest..."
docker build -t weaklink-labs/lab-setup:latest \
    -f "${SCRIPT_DIR}/images/lab-setup/Dockerfile" \
    "${SCRIPT_DIR}" 2>&1 | tail -1
ok "weaklink-labs/lab-setup:latest built."

# ============================================================
# Step 5: Deploy via Helm
# ============================================================

header "Deploying to Kubernetes..."

log "Running helm upgrade --install..."
helm upgrade --install weaklink-labs \
    "${SCRIPT_DIR}/helm/weaklink-labs" \
    -n weaklink --create-namespace \
    --wait --timeout 5m \
    2>&1 | sed 's/^/  /'
ok "Helm release deployed."

# ============================================================
# Step 6: Wait for pods to be ready
# ============================================================

header "Waiting for pods to be ready..."

COMPONENTS=("pypi-private" "pypi-public" "verdaccio" "gitea" "registry" "guide" "workstation")

for component in "${COMPONENTS[@]}"; do
    log "Waiting for ${component}..."
    kubectl wait --for=condition=available \
        deployment/"$component" \
        -n weaklink \
        --timeout=120s 2>/dev/null \
        && ok "${component} is ready." \
        || warn "${component} may not be ready yet."
done

# Wait for the lab-setup job
log "Waiting for lab-setup job to complete..."
# The job is created by a Helm hook, so give it a moment to appear
sleep 5
if kubectl get job lab-setup -n weaklink &>/dev/null; then
    kubectl wait --for=condition=complete \
        job/lab-setup \
        -n weaklink \
        --timeout=300s 2>/dev/null \
        && ok "Lab setup complete." \
        || warn "Lab setup still running. Check logs: kubectl logs -n weaklink job/lab-setup"
else
    warn "Lab setup job not found yet. It will run shortly."
fi

# ============================================================
# Step 7: Start port-forward and print access information
# ============================================================

# On macOS with Docker driver, NodePort isn't directly reachable.
# Port-forward is the reliable cross-platform approach.
log "Starting port-forward for guide (localhost:8000)..."
kubectl port-forward -n weaklink svc/guide 8000:8000 &>/dev/null &
GUIDE_PF_PID=$!
echo "$GUIDE_PF_PID" > "${SCRIPT_DIR}/.weaklink-pf.pid"
ok "Guide port-forward started (PID: $GUIDE_PF_PID)."

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD}  WeakLink Labs is ready!${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo -e "  Guide:       ${CYAN}http://localhost:8000${NC}"
echo -e "  Workstation: ${CYAN}./cli/weaklink shell${NC}"
echo ""
echo -e "  ${DIM}Useful commands:${NC}"
echo -e "    ${BOLD}./cli/weaklink shell${NC}     Open a shell in the workstation"
echo -e "    ${BOLD}./cli/weaklink path${NC}      Show the learning roadmap"
echo -e "    ${BOLD}./cli/weaklink status${NC}    Check pod status"
echo -e "    ${BOLD}./cli/weaklink logs${NC}      View setup job logs"
echo -e "    ${BOLD}./stop.sh${NC}                Tear everything down"
echo ""

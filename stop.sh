#!/usr/bin/env bash
#
# WeakLink Labs -- Stop
# Tear down the platform.
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "${CYAN}[*]${NC} $*"; }
ok()   { echo -e "${GREEN}[+]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }

echo ""
echo -e "${BOLD}WeakLink Labs -- Teardown${NC}"
echo ""

# Kill port-forwards if running
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/.weaklink-pf.pid" ]]; then
    PF_PID=$(cat "${SCRIPT_DIR}/.weaklink-pf.pid")
    kill "$PF_PID" 2>/dev/null && ok "Guide port-forward stopped." || true
    rm -f "${SCRIPT_DIR}/.weaklink-pf.pid"
fi
if [[ -f "${SCRIPT_DIR}/.weaklink-pf-ttyd.pid" ]]; then
    TTYD_PID=$(cat "${SCRIPT_DIR}/.weaklink-pf-ttyd.pid")
    kill "$TTYD_PID" 2>/dev/null && ok "Web terminal port-forward stopped." || true
    rm -f "${SCRIPT_DIR}/.weaklink-pf-ttyd.pid"
fi
if [[ -f "${SCRIPT_DIR}/.weaklink-pf-verify.pid" ]]; then
    VERIFY_PID=$(cat "${SCRIPT_DIR}/.weaklink-pf-verify.pid")
    kill "$VERIFY_PID" 2>/dev/null && ok "Verify API port-forward stopped." || true
    rm -f "${SCRIPT_DIR}/.weaklink-pf-verify.pid"
fi

# Uninstall Helm release
log "Uninstalling Helm release..."
if helm list -n weaklink 2>/dev/null | grep -q weaklink-labs; then
    helm uninstall weaklink-labs -n weaklink 2>&1 | sed 's/^/  /'
    ok "Helm release uninstalled."
else
    warn "No Helm release found in weaklink namespace."
fi

# Delete namespace (cleans up PVCs and any leftover resources)
log "Deleting weaklink namespace..."
kubectl delete namespace weaklink --ignore-not-found 2>&1 | sed 's/^/  /'
ok "Namespace deleted."

# Optionally stop minikube
echo ""
read -p "Stop minikube too? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Stopping minikube..."
    minikube stop 2>&1 | sed 's/^/  /'
    ok "minikube stopped."
else
    ok "minikube left running."
fi

echo ""
ok "WeakLink Labs torn down."
echo ""

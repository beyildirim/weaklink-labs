#!/bin/bash
#
# WeakLink Labs — Sign Docker Images with Cosign
#
# Signs all lab Docker images with Cosign, demonstrating the exact
# practice taught in Lab 4.3 (Signing Fundamentals).
#
# Usage:
#   ./scripts/sign-images.sh              # Sign with local key
#   ./scripts/sign-images.sh --keyless    # Sign with Sigstore keyless (OIDC)
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KEY_DIR="${PROJECT_ROOT}/.cosign"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

log()  { echo -e "${CYAN}[*]${NC} $*"; }
ok()   { echo -e "${GREEN}[+]${NC} $*"; }
err()  { echo -e "${RED}[-]${NC} $*"; }

IMAGES=(
    "weaklink-labs/guide:latest"
    "weaklink-labs/workstation:latest"
    "weaklink-labs/lab-setup:latest"
)

KEYLESS=false
if [[ "${1:-}" == "--keyless" ]]; then
    KEYLESS=true
fi

# ──────────────────────────────────────────────
# Preflight
# ──────────────────────────────────────────────

if ! command -v cosign &>/dev/null; then
    err "cosign not found. Install it:"
    echo -e "  ${DIM}brew install cosign${NC}"
    echo -e "  ${DIM}go install github.com/sigstore/cosign/v2/cmd/cosign@latest${NC}"
    exit 1
fi

# ──────────────────────────────────────────────
# Key management
# ──────────────────────────────────────────────

if [[ "$KEYLESS" == "false" ]]; then
    if [[ ! -f "${KEY_DIR}/cosign.key" ]]; then
        log "Generating Cosign key pair in ${KEY_DIR}..."
        mkdir -p "$KEY_DIR"
        COSIGN_PASSWORD="" cosign generate-key-pair --output-key-prefix="${KEY_DIR}/cosign"
        ok "Key pair generated."
        echo -e "  ${DIM}Public key:  ${KEY_DIR}/cosign.pub${NC}"
        echo -e "  ${DIM}Private key: ${KEY_DIR}/cosign.key (keep this safe!)${NC}"

        # Add private key to gitignore if not already there
        if ! grep -q ".cosign/cosign.key" "${PROJECT_ROOT}/.gitignore" 2>/dev/null; then
            echo -e "\n# Cosign signing keys (never commit private key)\n.cosign/cosign.key" >> "${PROJECT_ROOT}/.gitignore"
        fi
    else
        ok "Using existing key pair from ${KEY_DIR}/"
    fi
fi

# ──────────────────────────────────────────────
# Sign images
# ──────────────────────────────────────────────

echo ""
echo -e "${BOLD}Signing WeakLink Labs Docker images...${NC}"
echo ""

SIGNED=0
FAILED=0

for image in "${IMAGES[@]}"; do
    log "Signing ${image}..."

    if [[ "$KEYLESS" == "true" ]]; then
        if COSIGN_EXPERIMENTAL=1 cosign sign "$image" 2>&1; then
            ok "  ${image} signed (keyless/Sigstore)"
            SIGNED=$((SIGNED + 1))
        else
            err "  Failed to sign ${image}"
            FAILED=$((FAILED + 1))
        fi
    else
        if COSIGN_PASSWORD="" cosign sign --key="${KEY_DIR}/cosign.key" "$image" 2>&1; then
            ok "  ${image} signed"
            SIGNED=$((SIGNED + 1))
        else
            err "  Failed to sign ${image}"
            FAILED=$((FAILED + 1))
        fi
    fi
done

echo ""
echo -e "${BOLD}=== Signing Summary ===${NC}"
echo -e "  Signed: ${SIGNED}"
echo -e "  Failed: ${FAILED}"

if [[ "$KEYLESS" == "false" ]]; then
    echo ""
    echo -e "${BOLD}Verify with:${NC}"
    echo -e "  ${DIM}cosign verify --key ${KEY_DIR}/cosign.pub <image>${NC}"
fi

echo ""
exit $FAILED

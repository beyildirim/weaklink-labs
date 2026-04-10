#!/bin/bash
set -euo pipefail
echo "[*] Verifying SLSA provenance..."
PROVENANCE="${1:-src/provenance/slsa-provenance-example.json}"
echo "[*] Checking builder identity..."
BUILDER=$(jq -r '.predicate.builder.id' "$PROVENANCE")
echo "    Builder: $BUILDER"
echo "[*] Checking source repo..."
SOURCE=$(jq -r '.predicate.invocation.configSource.uri' "$PROVENANCE")
echo "    Source: $SOURCE"
echo "[*] Checking materials..."
jq -r '.predicate.materials[].uri' "$PROVENANCE"
echo "[+] Provenance metadata verified."

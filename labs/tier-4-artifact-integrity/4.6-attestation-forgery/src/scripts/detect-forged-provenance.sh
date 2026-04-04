#!/bin/bash
set -euo pipefail
echo "[*] Checking provenance authenticity..."
PROV="${1:-exploits/forged-provenance.json}"
BUILDER=$(jq -r '.predicate.builder.id' "$PROV")
echo "    Builder claims: $BUILDER"
echo "[!] To detect forgery:"
echo "    1. Verify the provenance signature (not just its content)"
echo "    2. Check the builder ID against a trusted builder list"
echo "    3. Verify the source commit exists in the claimed repo"
echo "    4. Cross-reference the Rekor transparency log"

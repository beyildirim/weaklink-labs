#!/bin/bash
set -euo pipefail
echo "[*] Comparing SBOM against actual installed packages..."
echo "[*] Generating fresh SBOM from the running container..."
echo "    pip list --format=json > /tmp/actual-packages.json"
echo "[*] Comparing against claimed SBOM..."
echo "    diff <(jq '.components[].name' claimed-sbom.json | sort) <(jq '.[].name' actual-packages.json | sort)"
echo "[!] Any package in the container but NOT in the SBOM = potential hidden malware"
echo "[!] Any package in the SBOM but NOT in the container = phantom dependency risk"

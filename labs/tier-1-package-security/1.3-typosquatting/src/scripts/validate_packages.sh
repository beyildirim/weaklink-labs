#!/bin/bash
#
# Package name allowlist validator
# ================================
# This script checks installed packages against an allowlist.
# Use it in CI/CD or as a pre-commit hook to catch typosquatting.
#

ALLOWLIST_FILE="${1:-/app/allowlist.txt}"

if [[ ! -f "$ALLOWLIST_FILE" ]]; then
    echo "[-] Allowlist file not found: $ALLOWLIST_FILE"
    echo "    Create one with: pip freeze | cut -d= -f1 > allowlist.txt"
    exit 1
fi

echo "[*] Validating installed packages against allowlist..."

VIOLATIONS=0
while IFS= read -r pkg; do
    # Skip comments and empty lines
    [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue

    # Extract package name (handle name==version format)
    pkg_name=$(echo "$pkg" | cut -d= -f1 | tr '[:upper:]' '[:lower:]')

    if ! grep -qi "^${pkg_name}$" "$ALLOWLIST_FILE"; then
        echo "    [!] UNAUTHORIZED: ${pkg_name} is not in the allowlist"
        VIOLATIONS=$((VIOLATIONS + 1))
    fi
done < <(pip freeze 2>/dev/null)

if [[ $VIOLATIONS -gt 0 ]]; then
    echo "[-] Found ${VIOLATIONS} unauthorized package(s)!"
    exit 1
else
    echo "[+] All packages are authorized."
    exit 0
fi

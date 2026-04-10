#!/bin/bash
#
# CI Check: Verify lockfile integrity
# ====================================
# This script regenerates the lockfile from requirements.in and compares
# it against the committed lockfile. If they differ, someone may have
# tampered with the lockfile.
#
# Usage: ./verify-lockfile.sh [requirements.in] [requirements.txt]
#

set -uo pipefail

REQ_IN="${1:-requirements.in}"
REQ_TXT="${2:-requirements.txt}"

if [[ ! -f "$REQ_IN" ]]; then
    echo "[-] Source file not found: $REQ_IN"
    exit 1
fi

if [[ ! -f "$REQ_TXT" ]]; then
    echo "[-] Lockfile not found: $REQ_TXT"
    exit 1
fi

echo "[*] Regenerating lockfile from ${REQ_IN}..."

TMPFILE=$(mktemp)
pip-compile --generate-hashes \
    --index-url http://pypi-private:8080/simple/ \
    --trusted-host pypi-private \
    --quiet \
    "$REQ_IN" \
    --output-file "$TMPFILE" 2>/dev/null

if [[ $? -ne 0 ]]; then
    echo "[-] pip-compile failed"
    rm -f "$TMPFILE"
    exit 1
fi

# Compare (ignore comment lines that contain timestamps)
DIFF=$(diff <(grep -v "^#" "$REQ_TXT" | grep -v "^$") <(grep -v "^#" "$TMPFILE" | grep -v "^$"))

rm -f "$TMPFILE"

if [[ -z "$DIFF" ]]; then
    echo "[+] Lockfile is consistent with ${REQ_IN}. No tampering detected."
    exit 0
else
    echo "[-] LOCKFILE MISMATCH DETECTED!"
    echo ""
    echo "    The committed lockfile does not match a fresh generation from ${REQ_IN}."
    echo "    This could indicate lockfile tampering."
    echo ""
    echo "    Diff:"
    echo "$DIFF" | sed 's/^/    /'
    echo ""
    echo "    To fix: pip-compile --generate-hashes ${REQ_IN} > ${REQ_TXT}"
    exit 1
fi

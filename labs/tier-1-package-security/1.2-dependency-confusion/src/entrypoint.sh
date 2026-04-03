#!/bin/bash
# Wait for PyPI servers to be ready
echo "Waiting for private PyPI server..."
until curl -sf http://private-pypi:8080/simple/ > /dev/null 2>&1; do
    sleep 1
done
echo "Private PyPI ready."

echo "Waiting for public PyPI server..."
until curl -sf http://public-pypi:8080/simple/ > /dev/null 2>&1; do
    sleep 1
done
echo "Public PyPI ready."

# Clean any previous compromise marker
rm -f /tmp/dependency-confusion-pwned

echo ""
echo "==================================================="
echo "  Lab 1.2: Dependency Confusion Attack"
echo "==================================================="
echo ""
echo "  You are a developer at ACME Corp."
echo "  Your app is in /app/"
echo ""
echo "  See the README for full instructions."
echo "==================================================="
echo ""

exec sleep infinity

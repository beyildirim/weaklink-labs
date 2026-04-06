#!/bin/bash
# Wait for PyPI servers to be ready
echo "Waiting for private PyPI server..."
until curl -sf http://pypi-private:8080/simple/ > /dev/null 2>&1; do
    sleep 1
done
echo "Private PyPI ready."

echo "Waiting for public PyPI server..."
until curl -sf http://pypi-public:8080/simple/ > /dev/null 2>&1; do
    sleep 1
done
echo "Public PyPI ready."

echo ""
echo "==================================================="
echo "  Lab 1.1: How Dependency Resolution Works"
echo "==================================================="
echo ""
echo "  Your app is in /app/"
echo "  Run: pip install -r requirements.txt"
echo "  Then: python app.py"
echo ""
echo "  See the README for full instructions."
echo "==================================================="
echo ""

exec sleep infinity

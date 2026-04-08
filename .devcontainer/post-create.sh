#!/bin/bash
set -e

echo "==> Setting up WeakLink Labs..."

# Install the weaklink CLI
chmod +x /workspaces/weaklink-labs/cli/weaklink
sudo ln -sf /workspaces/weaklink-labs/cli/weaklink /usr/local/bin/weaklink

# Install common tools used across labs
pip install --quiet pip-audit pipdeptree

# Create progress tracking directory
mkdir -p ~/.weaklink

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║   WeakLink Labs - Ready!                         ║"
echo "  ║                                                  ║"
echo "  ║   Run 'weaklink path' to see the learning roadmap║"
echo "  ║   Run 'weaklink start 0.1' to begin              ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

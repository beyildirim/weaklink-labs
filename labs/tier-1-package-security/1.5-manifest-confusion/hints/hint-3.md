# Hint 3: Complete Solution

```bash
# Clean everything
cd /workspace
rm -rf node_modules package-lock.json
rm -f /tmp/manifest-confusion-pwned

# Use only the safe package
cat > package.json << 'EOF'
{
  "name": "victim-app",
  "version": "1.0.0",
  "dependencies": {
    "safe-utils": "1.0.0"
  }
}
EOF

# Install (generates lockfile with integrity hashes)
npm install

# Verify: lockfile has integrity
grep '"integrity"' package-lock.json

# Verify: no evil-pkg
ls node_modules/evil-pkg 2>/dev/null || echo "Clean: no evil-pkg"

# Verify: no pwned marker
test ! -f /tmp/manifest-confusion-pwned && echo "Clean: not pwned"

# The compare-manifests tool is already installed at /usr/local/bin/compare-manifests
# Test it:
compare-manifests safe-utils     # Should show CLEAN
compare-manifests crafted-widget # Should show MISMATCH
```

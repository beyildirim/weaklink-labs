# Hint 3: Complete Solution

```bash
cd /workspace
rm -rf node_modules package-lock.json
rm -f /tmp/phantom-dep-pwned

# Fix package.json: add debug as explicit dependency
cat > package.json << 'EOF'
{
  "name": "phantom-demo-app",
  "version": "1.0.0",
  "description": "An app with properly declared dependencies",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "wl-framework": "1.0.0",
    "debug": "4.3.4"
  }
}
EOF

# Install (generates lockfile)
npm install

# Verify it works
node app.js &
sleep 2
kill %1

# Run depcheck — should be clean
depcheck /workspace

# Verify lockfile exists
ls -la package-lock.json
```

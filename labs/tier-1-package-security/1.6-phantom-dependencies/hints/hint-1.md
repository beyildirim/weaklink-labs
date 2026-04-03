# Hint 1: Finding the Problem

A phantom dependency is a package you `require()` in your code that isn't in your `package.json`.

To find them:
```bash
# Quick check: is debug in package.json?
cat package.json | grep debug

# Use depcheck to find all phantom deps:
depcheck /workspace

# Check the dependency tree:
npm ls debug
```

The issue: `app.js` does `require('debug')` but `package.json` only lists `acme-framework`.
It works by accident because npm hoists `acme-framework`'s dependency on `debug` to the root `node_modules/`.

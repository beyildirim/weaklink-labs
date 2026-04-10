# Lab 1.5: Manifest Confusion

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Detecting Manifest Mismatches

### Step 1: Clean up

```bash
cd /app
rm -rf node_modules package-lock.json
rm -f /tmp/manifest-confusion-pwned
```

### Step 2: Use the manifest comparison tool

```bash
bash /app/compare-manifests.sh crafted-widget
```

Should show `[MISMATCH]`.

```bash
bash /app/compare-manifests.sh safe-utils
```

Should show `[CLEAN]`.

### Step 3: Inspect before you install

```bash
mkdir -p /tmp/audit && cd /tmp/audit
npm pack crafted-widget
tar xzf crafted-widget-2.1.0.tgz
cat package/package.json
```

The hidden `evil-pkg` dependency and `postinstall` script are visible.

### Step 4: Install from a verified lockfile with integrity hashes

```bash
cd /app
rm -rf node_modules package-lock.json

cat > package.json << 'EOF'
{
  "name": "victim-app",
  "version": "1.0.0",
  "dependencies": {
    "safe-utils": "1.0.0"
  }
}
EOF

npm install
```

Verify integrity hashes:

```bash
cat package-lock.json | grep -A2 '"integrity"'
```

Use `npm ci` (enforces the lockfile exactly):

```bash
rm -rf node_modules
npm ci
```

`npm ci` is only safe if the `package-lock.json` was generated from a trustworthy `npm install`. If the lockfile itself was generated while the registry metadata was compromised, `npm ci` will faithfully reproduce the compromise. Always verify lockfile changes in code review.

### Step 5: Verify the defense

```bash
ls node_modules/evil-pkg 2>/dev/null && echo "FAIL: evil-pkg found" || echo "PASS: no evil-pkg"
test -f /tmp/manifest-confusion-pwned && echo "FAIL: pwned" || echo "PASS: not pwned"
grep -q '"integrity"' package-lock.json && echo "PASS: lockfile has integrity hashes" || echo "FAIL: no integrity"
test -x /app/compare-manifests.sh && echo "PASS: comparison tool available" || echo "FAIL: no tool"
```

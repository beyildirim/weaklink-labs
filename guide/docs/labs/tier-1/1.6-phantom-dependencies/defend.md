# Lab 1.6: Phantom Dependencies

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

## Declaring and Pinning All Dependencies

### Step 1: Clean up

```bash
cd /workspace
rm -rf node_modules package-lock.json
rm -f /tmp/phantom-dep-pwned
```

### Step 2: Find all phantom dependencies

```bash
depcheck /workspace
```

### Step 3: Add debug as an explicit, pinned dependency

```bash
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
```

`debug` is now explicit with a pinned version (`4.3.4`, not `^4.3.4`).

### Step 4: Install and verify

```bash
npm install
node app.js
```

### Step 5: Use npm ci for reproducible installs

```bash
rm -rf node_modules
npm ci
```

### Step 6: Re-run depcheck

```bash
depcheck /workspace
```

No more phantom dependencies.

### Step 7: Test the defense against the attack

```bash
npm update
npm ls debug
node app.js
test ! -f /tmp/phantom-dep-pwned && echo "PASS: not compromised"
```

Because `debug@4.3.4` is explicitly declared and pinned, `npm update` won't replace it with `99.0.0`.

### Verify your defenses

```bash
weaklink verify 1.6
```

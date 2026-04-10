# Lab 1.5: Manifest Confusion

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## Exploiting Manifest Confusion

### Step 1: Clean the environment

```bash
cd /app
rm -rf node_modules package.json package-lock.json
rm -f /tmp/manifest-confusion-pwned
```

### Step 2: Create a project that depends on crafted-widget

```bash
cat > package.json << 'EOF'
{
  "name": "victim-app",
  "version": "1.0.0",
  "dependencies": {
    "crafted-widget": "^2.1.0"
  }
}
EOF
```

### Step 3: Audit before installing

```bash
npm view crafted-widget dependencies
```

Output: `{ lodash: '^4.17.21' }`. Looks safe. No suspicious dependencies.

### Step 4: Install the package

```bash
npm install
```

`evil-pkg` gets installed and its postinstall script runs.

### Step 5: Verify the attack

```bash
cat /tmp/manifest-confusion-pwned
ls node_modules/evil-pkg/
cat node_modules/crafted-widget/package.json | head -20
```

What happened:

1. `npm view` showed only `lodash` as a dependency
2. `npm install` downloaded the **tarball**, which contained `evil-pkg`
3. npm installed `evil-pkg` and ran its `postinstall` script
4. **Every security tool that trusts registry metadata would have missed this**

**Checkpoint:** You should now have `/tmp/manifest-confusion-pwned` present, `evil-pkg` in `node_modules/`, and a clear understanding of the metadata/tarball mismatch.

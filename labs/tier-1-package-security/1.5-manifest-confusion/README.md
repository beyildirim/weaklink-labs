# Lab 1.5: Manifest Confusion

> Legacy note: The canonical learner-facing version of this lab lives in the browser guide. Start the platform with `make start`, open the guide, and use the built-in terminal. Treat this README as a secondary local reference.

In 2023, security researcher Darcy Clarke discovered a fundamental flaw in the npm ecosystem: the package metadata that `npm view` shows you can differ from what's actually inside the tarball you install. Auditing tools, security scanners, and developers all trusted the registry API, but the registry was lying.

This lab teaches you how npm packages are published, how registry metadata can be manipulated, and how to detect and defend against manifest confusion attacks.

## Prerequisites

- Labs 1.1 through 1.4 completed
- Basic familiarity with npm and Node.js
- Understanding of how package registries work

## Environment

| Service | URL | Purpose |
|---------|-----|---------|
| **Verdaccio** | http://verdaccio:4873 | Local npm registry with crafted packages |
| **workspace** | Browser terminal | Your working shell |

Packages pre-loaded on the registry:
- `safe-utils@1.0.0`: a normal, legitimate package
- `crafted-widget@2.1.0`: a package with **mismatched manifests** (the attack)
- `evil-pkg@1.0.0`: the hidden malicious dependency

## Start the Lab

```bash
make start
```

Then open the guide in your browser and use the built-in terminal.

---

## Phase 1: Understand

### How npm packages are published

When a developer publishes a package, two things happen:

1. `npm pack` creates a `.tgz` tarball containing the code and `package.json`
2. `npm publish` uploads that tarball to the registry, which extracts metadata from it

The registry then serves **two things** for each package:
- **Metadata** (via the API): what `npm view` shows, including name, version, dependencies, scripts
- **Tarball** (the download): what `npm install` actually extracts into `node_modules/`

### Step 1: Inspect a normal package via the registry API

```bash
npm view safe-utils
```

Note the dependencies listed (`lodash`), the version, and the description.

### Step 2: Download and inspect the actual tarball

```bash
mkdir /tmp/inspect && cd /tmp/inspect
npm pack safe-utils
tar xzf safe-utils-1.0.0.tgz
cat package/package.json
```

Compare what you see here with what `npm view` showed. For a normal package, they match.

### Step 3: Now check the crafted package

```bash
npm view crafted-widget
```

Look at the dependencies. What do you see? Just `lodash`. Looks safe, right?

### Step 4: Download and inspect the crafted package tarball

```bash
cd /tmp/inspect
npm pack crafted-widget
tar xzf crafted-widget-2.1.0.tgz
cat package/package.json
```

**Look carefully at the dependencies and scripts.** Compare them to what `npm view` showed.

You should see:
- The tarball has `"evil-pkg": "*"` in dependencies. The registry API did NOT show this
- The tarball has a `postinstall` script. The registry API did NOT show this

This is **manifest confusion**: the registry metadata and the tarball contents disagree.

### Key Insight

Any tool that relies on `npm view` or the registry API to audit packages will miss what's actually installed. The attack surface is the gap between what the registry **says** and what the tarball **contains**.

---

## Phase 2: Break

### Step 1: Clean the environment

```bash
cd /workspace
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

### Step 3: Audit before installing (the false sense of security)

If you were a security team, you'd probably check what this dependency pulls in:

```bash
npm view crafted-widget dependencies
```

Output: `{ lodash: '^4.17.21' }`. Looks safe. No suspicious dependencies.

### Step 4: Install the package

```bash
npm install
```

Watch the output. You'll see `evil-pkg` being installed and its postinstall script running.

### Step 5: Verify the attack

```bash
# The malicious postinstall script wrote a marker file
cat /tmp/manifest-confusion-pwned

# evil-pkg is in node_modules — but was NEVER shown by npm view
ls node_modules/evil-pkg/

# The crafted-widget tarball had dependencies the registry lied about
cat node_modules/crafted-widget/package.json | head -20
```

### What just happened?

1. You checked `npm view crafted-widget`. It showed only `lodash` as a dependency
2. You installed `crafted-widget`. npm downloaded the **tarball**, which contained `evil-pkg` as a dependency
3. npm installed `evil-pkg` and ran its `postinstall` script, which wrote to `/tmp/manifest-confusion-pwned`
4. **Every security tool that trusts registry metadata would have missed this entirely**

### Real-world impact

This vulnerability (CVE-2022-25881 / Darcy Clarke's disclosure) affected:
- `npm audit` used registry metadata, not tarball contents
- Socket.dev, Snyk, and other security scanners at the time
- GitHub's dependency graph
- Any tool calling the npm registry API to determine dependencies

---

## Phase 3: Defend

### Step 1: Clean up the attack evidence

```bash
cd /workspace
rm -rf node_modules package-lock.json
rm -f /tmp/manifest-confusion-pwned
```

### Step 2: Use the manifest comparison tool

The lab includes a Python comparison helper that checks for mismatches:

```bash
# Check the crafted package
python3 /app/compare_manifests.py crafted-widget
```

This should show a `[MISMATCH]` result with the differences between registry and tarball.

```bash
# Compare with a normal package
python3 /app/compare_manifests.py safe-utils
```

This should show `[CLEAN]`.

### Step 3: Inspect before you install

Always extract and inspect the tarball before trusting a package:

```bash
mkdir -p /tmp/audit && cd /tmp/audit
npm pack crafted-widget
tar xzf crafted-widget-2.1.0.tgz
cat package/package.json
```

You can now see the hidden `evil-pkg` dependency and the `postinstall` script.

### Step 4: Install from a verified lockfile with integrity hashes

Create a clean `package.json` with only the safe dependency:

```bash
cd /workspace
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
```

Generate a lockfile with integrity hashes:

```bash
npm install
```

Verify the lockfile has integrity hashes:

```bash
cat package-lock.json | grep -A2 '"integrity"'
```

Now use `npm ci` (clean install). This enforces the lockfile exactly:

```bash
rm -rf node_modules
npm ci
```

### Step 5: Verify the defense

```bash
# No evil-pkg in node_modules
ls node_modules/evil-pkg 2>/dev/null && echo "FAIL: evil-pkg found" || echo "PASS: no evil-pkg"

# No compromise marker
test -f /tmp/manifest-confusion-pwned && echo "FAIL: pwned" || echo "PASS: not pwned"

# Lockfile exists with integrity
grep -q '"integrity"' package-lock.json && echo "PASS: lockfile has integrity hashes" || echo "FAIL: no integrity"

# Comparison script exists
test -f /app/compare_manifests.py && echo "PASS: comparison tool available" || echo "FAIL: no tool"
```

### Step 6: Write your own comparison script (optional challenge)

Create `/workspace/check_manifest.py` that:
1. Takes a package name as argument
2. Fetches registry metadata via `curl`
3. Downloads and extracts the tarball
4. Compares the two `package.json` files
5. Exits non-zero if they differ

You can reference `/lab/src/compare_manifests.py` as a starting point.

---

## What You Learned

| Concept | Real-World Application |
|---------|----------------------|
| Registry metadata vs tarball contents | Never trust `npm view` output for security decisions |
| Manifest confusion attack | CVE disclosed by Darcy Clarke, affected the entire npm ecosystem |
| Tarball inspection | Always `npm pack` + extract to see what you're actually installing |
| Lockfile integrity hashes | `package-lock.json` with `integrity` fields catches tampering |
| `npm ci` vs `npm install` | `npm ci` strictly follows the lockfile; `npm install` can modify it |

## Further Reading

- [Darcy Clarke: "The massive hole in the npm ecosystem"](https://blog.vlt.sh/blog/the-massive-hole-in-the-npm-ecosystem), the original disclosure
- [GitHub Advisory: Manifest Confusion](https://github.blog/2023-07-12-introducing-npm-package-provenance/), npm's response with package provenance
- [npm RFC: Package Provenance](https://github.com/npm/rfcs/pull/626), the fix proposal
- [Socket.dev](https://socket.dev/), a scanner that checks actual package contents, not just metadata

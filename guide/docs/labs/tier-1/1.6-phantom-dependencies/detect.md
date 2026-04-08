# Lab 1.6: Phantom Dependencies

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

## Finding Phantom Dependencies in Production

Phantom dependency exploitation has two phases: *silent reliance* (your code uses undeclared packages) and *substitution* (an attacker publishes a malicious version that fills the gap).

What to look for:

- `depcheck` reports `require()` / `import` statements for packages not in `package.json`
- `npm ls <package>` shows a package as transitive, but your code imports it directly
- A previously-transitive package suddenly appears at a significantly higher version (e.g., `debug@4.3.4` to `debug@99.0.0`)
- New packages appear in `node_modules/` after `npm update` that were never in `package.json`
- Outbound network connections from packages that previously had no network activity

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Compromise Software Dependencies | **T1195.002** | Exploiting implicit dependency relationships in the package ecosystem |
| Supply Chain Compromise: Compromise Software Supply Chain | **T1195.001** | Attacker publishes a malicious version of a commonly-used transitive package |
| Hijack Execution Flow | **T1574.002** | Attacker places a malicious package where the resolver will find it, exploiting npm's hoisting mechanism |

---

### SOC Alert Rules

- **Proactive detection**: Run `depcheck` in CI and feed results to your SIEM. Any `require()` without a corresponding `package.json` entry is a phantom dependency. This is your pre-attack detection.
- **Version anomaly alerting**: Alert on package installs where the major version jumps by more than 10. Attackers use high version numbers to win resolution.
- **npm install vs npm ci**: If CI uses `npm install` instead of `npm ci`, it can modify the lockfile and resolve new versions at build time. `npm ci` strictly follows the lockfile.
- **Post-incident forensics**: Compare `ls node_modules/` against `package.json`. Every package not declared (directly or transitively via `npm ls --all`) is either hoisted or a substitution attack.

### CI Integration

`.github/workflows/phantom-deps.yml`:

```yaml
name: Detect Phantom Dependencies
on:
  pull_request:
    paths:
      - '**.js'
      - '**.ts'
      - 'package.json'
      - 'package-lock.json'
  push:
    branches: [main]

jobs:
  depcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies with npm ci
        run: |
          if ! npm ci; then
            echo "::error::npm ci failed. Lockfile may be out of sync with package.json."
            exit 1
          fi
      - name: Install depcheck
        run: npm install -g depcheck
      - name: Run depcheck for phantom dependencies
        run: |
          set -euo pipefail
          OUTPUT=$(depcheck . --json 2>/dev/null || true)
          MISSING=$(echo "$OUTPUT" | node -e "
            const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
            const missing = Object.keys(data.missing || {});
            if (missing.length > 0) {
              console.log('PHANTOM DEPENDENCIES FOUND:');
              missing.forEach(dep => {
                const files = data.missing[dep];
                console.log('  ' + dep + ' (used in: ' + files.join(', ') + ')');
              });
              process.exit(1);
            } else {
              console.log('No phantom dependencies detected.');
            }
          ")
          echo "$OUTPUT"
      - name: Check for high-version anomalies
        run: |
          node -e "
            const lockfile = require('./package-lock.json');
            const packages = lockfile.packages || {};
            let found = false;
            for (const [path, info] of Object.entries(packages)) {
              if (!path || !info.version) continue;
              const major = parseInt(info.version.split('.')[0]);
              if (major > 50) {
                console.log('WARNING: ' + path + ' has version ' + info.version + ' (suspiciously high)');
                found = true;
              }
            }
            if (found) process.exit(1);
            console.log('No version anomalies detected.');
          "

  enforce-npm-ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify no npm install in scripts
        run: |
          if grep -rn 'npm install' .github/ Dockerfile* Makefile 2>/dev/null | grep -v 'npm install -g' | grep -v '#'; then
            echo "::warning::Found 'npm install' in CI/build files. Use 'npm ci' for reproducible builds."
          fi
```

---

## What You Learned

1. **Phantom dependencies are a ticking time bomb**: packages your code uses but doesn't declare can disappear or be replaced at any time.
2. **npm hoisting makes them invisible**: transitive deps at root `node_modules/` are accidentally importable.
3. **`depcheck` + explicit pinning + `npm ci`**: the defense stack that eliminates the attack surface.

## Further Reading

- [Phantom dependencies in Node.js (Rush.js)](https://rushjs.io/pages/advanced/phantom_deps/)
- [depcheck on npm](https://www.npmjs.com/package/depcheck)
- [Yarn PnP](https://yarnpkg.com/features/pnp/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

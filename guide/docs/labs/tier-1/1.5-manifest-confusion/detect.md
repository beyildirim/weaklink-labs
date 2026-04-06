# Lab 1.5: Manifest Confusion

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

## Finding Manifest Confusion in Production

Manifest confusion is harder to detect than most supply chain attacks because the malicious payload is *invisible* to API-based tooling. Detection requires comparing both sources or monitoring what actually gets installed.

What to look for:

- `npm view <package>` shows different dependencies than what ends up in `node_modules/`
- A package's registry metadata shows zero install scripts, but the installed `package.json` contains one
- During `npm install`, packages are downloaded that don't appear in the dependency tree from `npm view`
- DNS lookups for domains referenced in hidden `postinstall` scripts
- Installed `node_modules/` contains packages not present in the dependency graph from `npm ls`

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Compromise Software Dependencies | **T1195.002** | A published package contains hidden dependencies not visible through the registry API |
| Masquerading: Match Legitimate Name | **T1036.005** | The package presents a clean manifest to auditing tools while hiding its true contents |
| Hijack Execution Flow | **T1574** | Hidden `postinstall` scripts hijack the normal install flow to execute attacker code |

---

### SOC Alert Rules

- **Blind spot in existing tooling**: Most dependency scanners historically relied on registry API metadata. If the registry lies, your scanner lies. Confirm your scanner checks tarball contents.
- **High-value detection**: Alert on any `postinstall` script execution from packages not on your known-good allowlist. A short allowlist (husky, esbuild, sharp, node-gyp, puppeteer) covers 90% of legitimate cases.
- **Pre-install audit**: `npm pack <package> && tar xzf <package>.tgz && diff <(npm view <package> dependencies) <(node -e "console.log(JSON.stringify(require('./package/package.json').dependencies))")`. If they differ, escalate.

### CI Integration

`.github/workflows/manifest-verify.yml`:

```yaml
name: Detect Manifest Confusion
on:
  pull_request:
    paths:
      - 'package.json'
      - 'package-lock.json'

jobs:
  check-manifests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Compare registry metadata vs tarball contents
        run: |
          set -euo pipefail
          FAILED=0
          DEPS=$(node -e "
            const pkg = require('./package.json');
            const deps = {...(pkg.dependencies || {}), ...(pkg.devDependencies || {})};
            console.log(Object.keys(deps).join('\n'));
          ")
          mkdir -p /tmp/manifest-check
          cd /tmp/manifest-check
          for dep in $DEPS; do
            echo "Checking $dep..."
            REGISTRY_DEPS=$(npm view "$dep" dependencies --json 2>/dev/null || echo "{}")
            REGISTRY_SCRIPTS=$(npm view "$dep" scripts --json 2>/dev/null || echo "{}")
            npm pack "$dep" --quiet 2>/dev/null
            TARBALL=$(ls -t *.tgz | head -1)
            tar xzf "$TARBALL"
            TARBALL_DEPS=$(node -e "console.log(JSON.stringify(require('./package/package.json').dependencies || {}))")
            TARBALL_SCRIPTS=$(node -e "console.log(JSON.stringify(require('./package/package.json').scripts || {}))")
            if [ "$REGISTRY_DEPS" != "$TARBALL_DEPS" ]; then
              echo "::error::MANIFEST CONFUSION in $dep: registry dependencies differ from tarball"
              FAILED=1
            fi
            if echo "$TARBALL_SCRIPTS" | grep -q "postinstall\|preinstall\|install" && \
               ! echo "$REGISTRY_SCRIPTS" | grep -q "postinstall\|preinstall\|install"; then
              echo "::error::HIDDEN INSTALL SCRIPT in $dep: tarball has install hooks not shown in registry"
              FAILED=1
            fi
            rm -rf package "$TARBALL"
          done
          if [ "$FAILED" -eq 1 ]; then
            exit 1
          fi
          echo "All package manifests verified."

      - name: Enforce npm ci over npm install
        run: npm ci
```

---

## What You Learned

1. **Registry metadata can lie**: `npm view` output and tarball contents can disagree, and `npm install` trusts the tarball.
2. **Tarball inspection is the only truth**: always `npm pack` + extract to see what you're actually installing.
3. **`npm ci` enforces the lockfile**: `npm install` can modify it, `npm ci` strictly follows it.

## Further Reading

- [Darcy Clarke: "The massive hole in the npm ecosystem"](https://blog.vlt.sh/blog/the-massive-hole-in-the-npm-ecosystem)
- [npm Package Provenance](https://github.blog/2023-07-12-introducing-npm-package-provenance/)
- [Socket.dev](https://socket.dev/)

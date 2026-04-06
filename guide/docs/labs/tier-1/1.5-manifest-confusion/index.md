# Lab 1.5: Manifest Confusion

<div class="lab-meta">
  <span>~25 min hands-on | ~10 min reference</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-1/1.1-dependency-resolution/">Lab 1.1</a>, <a href="../../tier-1/1.2-dependency-confusion/">Lab 1.2</a>, <a href="../../tier-1/1.3-typosquatting/">Lab 1.3</a>, <a href="../../tier-1/1.4-lockfile-injection/">Lab 1.4</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>

In 2023, Darcy Clarke discovered a fundamental flaw in the npm ecosystem: the package metadata that `npm view` shows can differ from what's actually inside the tarball you install. Auditing tools, security scanners, and developers all trusted the registry API. But the registry was lying.

### Attack Flow

```mermaid
graph LR
    A[Registry metadata says clean deps] --> B[Tarball has hidden dep]
    B --> C[npm install pulls tarball]
    C --> D[Hidden dep executes postinstall]
```

## Environment

| Service | Address | Purpose |
|---------|---------|---------|
| Verdaccio | `verdaccio:4873` | Local npm registry with crafted packages |

Packages pre-loaded:

- `safe-utils@1.0.0`: normal, legitimate package
- `crafted-widget@2.1.0`: **mismatched manifests** (the attack)
- `evil-pkg@1.0.0`: the hidden malicious dependency

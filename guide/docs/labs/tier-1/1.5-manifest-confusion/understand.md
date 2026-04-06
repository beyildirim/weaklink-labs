# Lab 1.5: Manifest Confusion

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## How npm Package Publishing Works

When a developer publishes a package, two things happen:

1. `npm pack` creates a `.tgz` tarball containing the code and `package.json`
2. `npm publish` uploads that tarball to the registry, which extracts metadata from it

The registry then serves **two things** for each package:

- **Metadata** (via the API): what `npm view` shows
- **Tarball** (the download): what `npm install` actually extracts into `node_modules/`

### Step 1: Inspect a normal package via the registry API

```bash
npm view safe-utils
```

### Step 2: Download and inspect the actual tarball

```bash
mkdir /tmp/inspect && cd /tmp/inspect
npm pack safe-utils
tar xzf safe-utils-1.0.0.tgz
cat package/package.json
```

Compare with what `npm view` showed. For a normal package, they match.

### Step 3: Check the crafted package

```bash
npm view crafted-widget
```

Dependencies show just `lodash`. Looks safe.

### Step 4: Download and inspect the crafted package tarball

```bash
cd /tmp/inspect
npm pack crafted-widget
tar xzf crafted-widget-2.1.0.tgz
cat package/package.json
```

**Compare the dependencies and scripts to what `npm view` showed:**

- The tarball has `"evil-pkg": "*"` in dependencies. The registry API did NOT show this.
- The tarball has a `postinstall` script. The registry API did NOT show this.

This is **manifest confusion**: the registry metadata and the tarball contents disagree. Any tool that relies on the registry API to audit packages will miss what's actually installed.

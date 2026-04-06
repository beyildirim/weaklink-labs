# Lab 2.7: Build Cache Poisoning

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

## Secure Cache Configuration

### Fix 1: Use lockfile hash as the only cache key

```bash
cd /repos/wl-webapp
git checkout main
```

```bash
cat > .gitea/workflows/ci.yml << 'EOF'
name: WeakLink Webapp CI

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: pip-${{ runner.os }}-${{ hashFiles('requirements.txt', 'requirements-lock.txt') }}
          # NO restore-keys -- never fall back to a stale cache

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Verify installed packages
        run: |
          pip install pip-audit
          pip-audit --require-hashes -r requirements-lock.txt

      - name: Run tests
        run: python test_app.py
EOF
```

### Fix 2: Generate a lockfile with hashes

```bash
pip install pip-tools
pip-compile --generate-hashes requirements.txt -o requirements-lock.txt
cat requirements-lock.txt
```

When `pip install --require-hashes` is used, pip verifies the downloaded wheel matches the hash. A poisoned wheel is rejected.

### Fix 3: Isolate PR caches from main

```bash
cat > .gitea/workflows/pr-ci.yml << 'EOF'
name: PR Validation

on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: pip-pr-${{ github.event.pull_request.number }}-${{ hashFiles('requirements.txt') }}
          restore-keys: |
            pip-pr-${{ github.event.pull_request.number }}-

      - name: Install and test
        run: |
          pip install -r requirements.txt
          python test_app.py
EOF
```

### Fix 4: Commit and push

```bash
git add -A
git commit -m "Secure CI cache: strict keys, hash verification, PR isolation"
git push origin main
```

### Key defenses

1. **Lockfile hashes as cache keys**. cache only matches when exact lockfile content matches
2. **No `restore-keys` on main**. never fall back to a stale cache
3. **Verify package hashes**. `pip install --require-hashes`, `npm ci`, `go mod verify`
4. **Isolate PR caches**. PR-specific keys that main branch builds cannot restore

### Step 5: Final verification

```bash
weaklink verify 2.7
```

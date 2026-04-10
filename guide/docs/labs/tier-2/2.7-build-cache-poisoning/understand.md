# Lab 2.7: Build Cache Poisoning

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

## How CI Caches Work

### Step 1: Examine the workflow with caching

```bash
cd /repos/wl-webapp
cat .gitea/workflows/ci.yml
```

The seeded vulnerable workflow uses a hashed key, but it also allows a broad fallback restore:

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: pip-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
    restore-keys: |
      pip-${{ runner.os }}-
```

### Step 2: Understand the trust boundary

The exact cache key is scoped to the dependency file, but the fallback is still broad enough to cross trust boundaries:

1. A PR build can write poisoned dependencies under the shared `pip-Linux-...` prefix
2. A later `main` build can restore that cache through `restore-keys`
3. `requirements.txt` still looks normal in code review
4. The compromise lives in cached bytes, not in protected source

### Step 3: Inspect the current cache contents

```bash
ls -la ~/.cache/pip/wheels/ 2>/dev/null
pip cache list 2>/dev/null
```

### Step 4: Understand the threat model

Cache poisoning succeeds when `restore-keys` fall back across trust boundaries, PR caches are not isolated from `main`, and restored dependencies are not verified before use.

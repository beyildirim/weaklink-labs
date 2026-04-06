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

Cache configuration:

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: pip-${{ runner.os }}-${{ hashFiles('requirements.txt') }}
    restore-keys: |
      pip-${{ runner.os }}-
```

### Step 2: Understand cache key resolution

Two-level lookup:

1. **Exact match**. `pip-Linux-abc123` (hash of `requirements.txt`)
2. **Prefix match** via `restore-keys`. `pip-Linux-` (matches ANY cache with this prefix)

The `restore-keys` fallback is the vulnerability. If the exact hash does not match, the cache system falls back to the most recent cache with a matching prefix. A cache created by a different branch can be restored, and an attacker who writes to the cache under a matching prefix poisons future builds.

### Step 3: Inspect the current cache contents

```bash
ls -la ~/.cache/pip/wheels/ 2>/dev/null
pip cache list 2>/dev/null
ls -la /runner/_work/_cache/ 2>/dev/null
```

### Step 4: Understand the threat model

Cache poisoning succeeds when: cache keys use weak prefixes (`restore-keys` matches broadly), PR caches are not isolated, cache contents are not verified, and lockfile hashes are not used as keys.

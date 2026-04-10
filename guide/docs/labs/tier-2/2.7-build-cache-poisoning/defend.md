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

The core lesson in this lab is not "write clever cache YAML." It is "treat cache state like untrusted input unless the key, scope, and integrity checks are all tight."

### Fix 1: Restore the hardened main workflow

```bash
cd /repos/wl-webapp
git checkout main
cp /lab/src/repo/.gitea/workflows/ci-safe-cache.yml .gitea/workflows/ci.yml
cat .gitea/workflows/ci.yml
```

The important properties are:

1. the main workflow only runs on `push`
2. the cache key depends on file hashes, not a static string
3. the workflow verifies what got installed instead of blindly trusting cache contents

### Fix 2: Restore isolated PR validation

```bash
cp /lab/src/repo/.gitea/workflows/pr-ci.yml .gitea/workflows/pr-ci.yml
cat .gitea/workflows/pr-ci.yml
```

The PR workflow uses a PR-scoped cache key so an untrusted branch does not write into the same cache namespace as `main`.

### Fix 3: Commit and push

```bash
git add -A
git commit -m "Harden CI cache keys and isolate PR cache"
git push origin main
```

### Key defenses

1. **Hashed cache keys** prevent cross-build reuse of unrelated state
2. **No broad fallback on main** means stale or poisoned caches are not silently restored
3. **Integrity checks** make the cache prove what it restored
4. **Separate PR cache scope** keeps untrusted branches out of the main cache namespace

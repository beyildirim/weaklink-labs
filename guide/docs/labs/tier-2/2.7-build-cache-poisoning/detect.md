# Lab 2.7: Build Cache Poisoning

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

## Catching Cache Poisoning

### MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| **Supply Chain Compromise: Compromise Software Supply Chain** | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Poisoning the build cache to inject malicious dependencies |
| **Hijack Execution Flow** | [T1574](https://attack.mitre.org/techniques/T1574/) | Replacing a legitimate cached dependency with a malicious one |

Cache poisoning is stealthy because builds appear to function normally. Detection focuses on cache key anomalies, unexpected cache restores, and hash mismatches.

Look for cache restores using `restore-keys` (prefix match) instead of exact key matches, cache key collisions across branches, package hash verification failures, cache size changes that do not correlate with lockfile changes, and PR-created caches being restored by default branch builds.

---

**Alerts you will see:**

- "Cache restored from prefix match on default branch" (CI audit)
- "Package hash verification failed during build" (build log monitoring)
- "Cache key collision detected across branches" (cache audit)

**Triage workflow:**

1. **Check the cache restore log**. exact key match or prefix fallback?
2. **Identify the cache source**. which workflow run created the restored cache?
3. **Compare cache contents** against known-good versions from the package registry
4. **Check lockfile hashes**. do cached wheels match the hashes in the lockfile?
5. **If confirmed: invalidate all caches** and rebuild from scratch
6. **Audit downstream artifacts**. any build using the poisoned cache is compromised

**False positive rate:** Low for hash verification failures. Medium for prefix match restores (normal but should be rare on default branch).

---

## CI Integration

**`.github/workflows/cache-integrity.yml`:**

```yaml
name: Cache Integrity Check

on:
  push:
    branches: [main]
    paths:
      - "requirements.txt"
      - "requirements-lock.txt"
      - "package-lock.json"

jobs:
  verify-cache:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Restore cache
        uses: actions/cache@v4
        id: cache
        with:
          path: ~/.cache/pip
          key: pip-${{ runner.os }}-${{ hashFiles('requirements-lock.txt') }}

      - name: Verify cached package integrity
        if: steps.cache.outputs.cache-hit == 'true'
        run: |
          echo "Cache was restored -- verifying integrity..."
          pip install --require-hashes \
            --no-deps \
            --no-index \
            --find-links ~/.cache/pip/wheels/ \
            -r requirements-lock.txt 2>&1 | tee /tmp/verify.log

          if grep -q "hash mismatch\|HASH MISMATCH" /tmp/verify.log; then
            echo "::error::Cache integrity check FAILED"
            rm -rf ~/.cache/pip/wheels/*
            exit 1
          fi
          echo "Cache integrity verified."

      - name: Fresh install on cache miss
        if: steps.cache.outputs.cache-hit != 'true'
        run: |
          pip install --require-hashes -r requirements-lock.txt
```

---

## What You Learned

1. **`restore-keys` enables prefix matching** that can restore stale or poisoned caches. Omit it on main.
2. **Lockfile hashes are the defense**. `--require-hashes` ensures cached packages match expected digests.
3. **PR caches must be isolated from main**. use PR-specific cache keys to prevent cross-branch poisoning.

## Further Reading

- [GitHub: Caching dependencies to speed up workflows](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [Legit Security: GitHub Actions Cache Poisoning](https://www.legitsecurity.com/blog/github-actions-cache-poisoning)
- [Snyk: Build Cache Poisoning in CI/CD](https://snyk.io/blog/cache-poisoning-in-github-actions/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

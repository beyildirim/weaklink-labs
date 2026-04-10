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

Cache poisoning is stealthy because builds appear to function normally. Detection focuses on shared cache keys, shared cache namespaces across trust boundaries, and integrity mismatches.

Look for shared cache keys used by both PR and default-branch workflows, unexpected cache restores after untrusted builds, package hash verification failures, cache size changes that do not correlate with dependency changes, and PR-created caches being restored by default branch builds.

---

**Alerts you will see:**

- "Shared cache key restored on default branch after PR run" (CI audit)
- "Package hash verification failed during build" (build log monitoring)
- "Cache key collision detected across branches" (cache audit)

**Triage workflow:**

1. **Check the cache restore log**. exact key, shared static key, or a fallback path?
2. **Identify the cache source**. which workflow run created the restored cache?
3. **Compare cache contents** against known-good versions from the package registry
4. **Check lockfile hashes**. do cached wheels match the hashes in the lockfile?
5. **If confirmed: invalidate all caches** and rebuild from scratch
6. **Audit downstream artifacts**. any build using the poisoned cache is compromised

**False positive rate:** Low for hash verification failures. Medium for shared-cache restores if your CI intentionally reuses the same key across branches.

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
          key: pip-${{ runner.os }}-${{ hashFiles('requirements.txt') }}

      - name: Verify cached package integrity
        if: steps.cache.outputs.cache-hit == 'true'
        run: |
          echo "Cache was restored -- verifying integrity..."
          pip install --dry-run -r requirements.txt 2>&1 | tee /tmp/verify.log

          if grep -q "hash mismatch\|HASH MISMATCH" /tmp/verify.log; then
            echo "::error::Cache integrity check FAILED"
            rm -rf ~/.cache/pip/wheels/*
            exit 1
          fi
          echo "Cache integrity verified."

      - name: Fresh install on cache miss
        if: steps.cache.outputs.cache-hit != 'true'
        run: |
          pip install -r requirements.txt
```

---

## What You Learned

1. **Shared cache keys are the core trust failure**. default branch and PRs must not restore the same writable cache.
2. **Exact cache keys plus integrity checks are the defense**. restored bytes must be both scoped and verified.
3. **PR caches must be isolated from main**. use PR-specific cache keys to prevent cross-branch poisoning.

## Further Reading

- [GitHub: Caching dependencies to speed up workflows](https://docs.github.com/en/actions/using-workflows/caching-dependencies-to-speed-up-workflows)
- [Legit Security: GitHub Actions Cache Poisoning](https://www.legitsecurity.com/blog/github-actions-cache-poisoning)
- [Snyk: Build Cache Poisoning in CI/CD](https://snyk.io/blog/cache-poisoning-in-github-actions/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

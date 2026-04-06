To defend against cache poisoning:

1. **Cache key based on lockfile hash.** The cache is invalidated when
   dependencies change:
   ```yaml
   key: pip-${{ hashFiles('requirements.txt') }}
   ```

2. **Separate caches for PRs and main.** PR caches cannot write to
   the main branch cache.

3. **Verify cache integrity.** Check hashes after restoring the cache.

Apply the defense:

```bash
cp /lab/src/repo/.gitea/workflows/ci-safe-cache.yml \
   /repos/wl-webapp/.gitea/workflows/ci.yml
```

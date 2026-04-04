To defend against cache poisoning:

1. **Cache key based on lockfile hash** -- cache is invalidated when
   dependencies change:
   ```yaml
   key: pip-${{ hashFiles('requirements.txt') }}
   ```

2. **Separate caches for PRs and main** -- PR caches cannot write to
   the main branch cache

3. **Verify cache integrity** -- check hashes after restoring cache

Apply the defense:

```bash
cp /lab/src/repo/.gitea/workflows/ci-safe-cache.yml \
   /repos/acme-webapp/.gitea/workflows/ci.yml
```

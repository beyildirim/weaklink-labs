The CI pipeline caches pip packages between builds. The cache key is
static (`pip-cache-v1`), meaning ANY build can write to the same cache.

A PR build can poison the cache with a modified package. The next main
branch build restores the poisoned cache and uses the malicious package.

Look at the cache configuration:

```bash
cat /repos/acme-webapp/.gitea/workflows/ci.yml
```

Notice the cache key is just a static string, not tied to the lockfile.

To poison the cache, create a modified version of a cached package in
the cache directory.

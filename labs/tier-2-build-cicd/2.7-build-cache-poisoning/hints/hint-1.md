The CI pipeline caches pip packages between builds. The dangerous part is
the broad `restore-keys` fallback, which lets one branch restore a cache
written by another branch.

A PR build can poison the cache with a modified package. The next main
branch build restores the poisoned cache through the shared prefix and
uses the malicious package.

Look at the cache configuration:

```bash
cat /repos/wl-webapp/.gitea/workflows/ci.yml
```

Notice the cache key uses dependency hashes, but `restore-keys` still
lets unrelated builds fall back to the same cache namespace.

To poison the cache, create a modified version of a cached package in
the cache directory.

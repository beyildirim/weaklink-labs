# Solution: Lab 5.1

## Key actions

1. Remove the untrusted public Helm repo:

```bash
helm repo remove untrusted-public
```

2. Update `Chart.yaml` to pin exact chart versions (replace `>=2.0.0` with `2.3.1`):

```yaml
dependencies:
  - name: redis
    version: "18.6.1"
    repository: "oci://private-registry:5000/charts"
```

3. Rebuild the lock file:

```bash
helm dependency update /app/webapp/
```

4. Verify the lock file contains digests:

```bash
cat /app/webapp/Chart.lock
```

## Why it works

- Exact version pins prevent Helm from resolving to a higher (malicious) version
- `Chart.lock` records SHA digests for each dependency, so any tampering is detected
- Removing untrusted repos eliminates the attack surface entirely
- Using OCI-based registries with authentication adds another layer of trust

# Lab 5.1: How Helm Charts Resolve Dependencies

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

## Pinning Charts and Locking Dependencies

### Step 1: Remove the untrusted repository

```bash
helm repo remove untrusted-public
helm repo list
```

### Step 2: Pin exact versions in Chart.yaml

```bash
cat > /app/webapp/Chart.yaml << 'EOF'
apiVersion: v2
name: webapp
description: Internal web application
type: application
version: 1.0.0
appVersion: "1.0.0"

dependencies:
  - name: redis
    version: "18.6.1"
    repository: "oci://private-registry:5000/charts"
  - name: postgresql
    version: "13.4.3"
    repository: "oci://private-registry:5000/charts"
  - name: nginx
    version: "1.2.0"
    repository: "oci://private-registry:5000/charts"
EOF
```

### Step 3: Rebuild the lock file

```bash
helm dependency update /app/webapp/
cat /app/webapp/Chart.lock
```

The lock file now contains exact versions with SHA256 digests.

### Step 4: Verify the defense

```bash
helm repo list
helm dependency list /app/webapp/
grep 'digest:' /app/webapp/Chart.lock
```


### Additional defenses

1. **OCI registries** support content-addressable storage with SHA digests, making substitution harder.
2. **Sign charts with Helm provenance.** `helm package --sign` creates a `.prov` file. `helm install --verify` checks it.
3. **Mirror charts locally** into your private registry and point all dependencies to it.
4. **Audit Chart.lock in CI.** Block PRs that modify Chart.yaml without updating Chart.lock.

# Lab 5.1: How Helm Charts Resolve Dependencies

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

## How Helm Resolves Chart Dependencies

### Step 1: Examine the application chart

```bash
cat /app/webapp/Chart.yaml
```

This chart depends on `redis`, `postgresql`, and `nginx`. Notice the version constraints:

- `redis` and `postgresql` use `>=` (range) from a public repo
- `nginx` uses an exact version from a private OCI registry

### Step 2: Check configured Helm repositories

```bash
helm repo list
```

Both `untrusted-public` and `private-charts` are configured. Helm searches all configured repos when resolving dependencies.

### Step 3: See what is available

```bash
# What versions does the public repo have?
helm search repo untrusted-public/redis --versions
helm search repo untrusted-public/postgresql --versions

# Helm repo aliases are searched separately from OCI registry URLs in Chart.yaml
helm search repo private-charts/ --versions
```

### Step 4: Resolve and download dependencies

```bash
helm dependency update /app/webapp/
```

With `>=18.0.0`, Helm picks the highest available version.

### Step 5: Inspect what was downloaded

```bash
ls -la /app/webapp/charts/
helm dependency list /app/webapp/
```

### Step 6: Understand Chart.lock

```bash
cat /app/webapp/Chart.lock
```

The lock file records exact versions and digests. If present, `helm dependency build` uses it instead of re-resolving. Without it, every `helm dependency update` can produce different results.

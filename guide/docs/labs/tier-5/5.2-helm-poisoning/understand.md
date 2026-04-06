# Lab 5.2: Helm Chart Poisoning

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

## Helm Templates, Hooks, and CRDs

### Step 1: Examine the chart structure

```bash
ls -la /app/metrics-aggregator/
cat /app/metrics-aggregator/Chart.yaml
ls -la /app/metrics-aggregator/templates/
```

A "metrics aggregation" chart with standard components: Deployment, Service, ServiceAccount, plus some additional template files.

### Step 2: Understand Helm hooks

Helm hooks are templates with the `helm.sh/hook` annotation. They run at specific lifecycle points:

| Hook | When It Runs |
|------|-------------|
| `pre-install` | Before any resources are created |
| `post-install` | After all resources are created |
| `pre-delete` | Before any resources are deleted |
| `post-delete` | After all resources are deleted |
| `pre-upgrade` | Before an upgrade |
| `post-upgrade` | After an upgrade |

A `post-install` hook with `hook-delete-policy: hook-succeeded` deletes itself after running, hiding the evidence.

### Step 3: Look at the values

```bash
cat /app/metrics-aggregator/values.yaml
```

### Step 4: Render the templates

```bash
helm template my-release /app/metrics-aggregator/
```

This shows all Kubernetes resources including hooks. Most engineers skip this step and go straight to `helm install`.

### Step 5: Count the resources

```bash
helm template my-release /app/metrics-aggregator/ | grep '^kind:' | sort | uniq -c
```

A simple metrics aggregator should have a Deployment, Service, and ServiceAccount. Anything else is worth investigating.

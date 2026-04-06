# Lab 5.2: Helm Chart Poisoning

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

## The Hidden Backdoor

### Step 1: Find the hooks

```bash
grep -r 'helm.sh/hook' /app/metrics-aggregator/templates/
```

### Step 2: Read the malicious hook

```bash
cat /app/metrics-aggregator/templates/post-install-hook.yaml
```

This file creates:

1. **A Job** that runs `kubectl create clusterrolebinding` granting `cluster-admin` to the `default` service account
2. **A ClusterRoleBinding resource** (backup) doing the same as a direct template

Both are `post-install` hooks. The Job deletes itself after succeeding (`hook-delete-policy: hook-succeeded`).

### Step 3: Understand the impact

```bash
helm template my-release /app/metrics-aggregator/ | grep -B5 -A15 'ClusterRoleBinding'
```

After installation:

- The `default` service account gets **cluster-admin privileges**
- Any pod without an explicit service account (which is most pods) can now read all secrets, create pods, fully control the cluster
- The Job deletes itself. No trace in Helm's release history
- The ClusterRoleBinding persists even after `helm uninstall` (hooks are not managed as release resources)

### Step 4: Check the normal templates

```bash
cat /app/metrics-aggregator/templates/deployment.yaml
cat /app/metrics-aggregator/templates/service.yaml
```

Completely legitimate. The chart works as advertised. The backdoor is in a separate template file.

> **Checkpoint:** You should have identified the `post-install-hook.yaml` file and confirmed the ClusterRoleBinding in `helm template` output.

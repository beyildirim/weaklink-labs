# Lab 5.1: How Helm Charts Resolve Dependencies

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

## Hijacking Chart Resolution

### Step 1: Examine the malicious chart

```bash
cat /app/malicious-redis-chart/Chart.yaml
```

Version 99.0.0. The attacker's chart.

### Step 2: Look at the malicious templates

```bash
cat /app/malicious-redis-chart/templates/post-install-exfil.yaml
```

The chart includes a legitimate redis deployment plus a `post-install` hook disguised as a "health check." This hook:

1. Reads the Kubernetes service account token from the pod filesystem
2. Sends it to `attacker.example.com` via HTTP POST
3. Prints "Health check completed successfully" to look normal

### Step 3: Simulate the attack

The attacker publishes v99.0.0 to the public repository. `helm dependency update` picks it because it satisfies `>=18.0.0`.

```bash
# Render the chart to see what would be deployed
helm template my-release /app/webapp/ 2>/dev/null | grep -A 30 'kind: Job'
```

The exfiltration job appears in the rendered output, buried among hundreds of lines of YAML.

### Step 4: Understand the blast radius

If installed on a real cluster:

- The post-install hook runs as a Kubernetes Job with access to `/var/run/secrets/`
- The attacker authenticates to the Kubernetes API with the service account token
- Depending on RBAC: read secrets, deploy pods, escalate privileges
- `helm install` output shows "deployed successfully"

> **Checkpoint:** Before continuing, you should have a resolved `Chart.lock` with the attacker's v99.0.0 redis chart, and have seen the exfiltration Job in `helm template` output.

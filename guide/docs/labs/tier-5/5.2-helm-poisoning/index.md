# Lab 5.2: Helm Chart Poisoning

<div class="lab-meta">
  <span>Understand: ~10 min | Break: ~10 min | Defend: ~10 min | Detect: ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../5.1-helm-resolution/">Lab 5.1</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="detect/" class="phase-step upcoming">Detect</a>
</div>

Helm charts can contain hooks, CRDs, and embedded scripts that run arbitrary code on your cluster. A `post-install` hook runs as a Kubernetes Job after `helm install`. A `pre-install` hook runs before. Both execute with whatever RBAC permissions the chart's service account has.

Chart poisoning is a trojanized chart with malicious hooks or templates. The deployment looks normal. The backdoor is silent and persistent.

### Attack Flow

```mermaid
graph LR
    A[Chart has post-install hook] --> B[Hook creates ClusterRoleBinding]
    B --> C[SA gets cluster-admin]
    C --> D[Backdoor persists]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Poisoned Chart | `/app/metrics-aggregator/` | Helm chart with a hidden post-install hook |
| Policies | `/app/policies/` | Directory for Kyverno/OPA policies (initially empty) |

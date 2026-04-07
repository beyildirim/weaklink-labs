# Lab 5.1: How Helm Charts Resolve Dependencies

<div class="lab-meta">
  <span>Phase 1: ~10 min | Phase 2: ~10 min | Phase 3: ~10 min | Phase 4: ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../../tier-0/0.3-containers/">Lab 0.3</a></span>
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

`helm dependency update` resolves chart dependencies from configured repositories. A `Chart.yaml` with `version: ">=18.0.0"` tells Helm "give me the highest match." If an attacker publishes a higher version on a public repo, Helm pulls it without question.

### Attack Flow

```mermaid
graph LR
    A[Chart.yaml lists dependency] --> B[helm dep update]
    B --> C[Fetches from repo]
    C --> D[Attacker publishes higher version]
    D --> E[Malicious chart installed]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Webapp Chart | `/app/webapp/` | Application Helm chart with dependencies |
| Malicious Chart | `/app/malicious-redis-chart/` | Attacker's redis chart v99.0.0 with exfil hook |
| Private Registry | `private-registry:5000` | Trusted OCI-based chart registry |
| Public Repo | `untrusted-public` | Simulated public Helm repository |

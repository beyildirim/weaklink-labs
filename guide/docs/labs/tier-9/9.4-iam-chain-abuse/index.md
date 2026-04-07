# Lab 9.4: IAM Chain Abuse

<div class="lab-meta">
  <span>Phase 1 ~10 min | Phase 2 ~15 min | Phase 3 ~15 min | Phase 4 ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-2/2.4-secret-exfiltration/">Lab 2.4</a></span>
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

Cloud IAM is itself a supply chain. Dev trusts CI, CI trusts Staging, Staging trusts Production. Each link is an `AssumeRole` policy. No individual link is wrong, but the transitive chain creates an attack path: compromise one developer's credentials, traverse four trust boundaries, reach production. 8 minutes, no alerts.

### Attack Flow

```mermaid
graph LR
    A[Dev account<br>compromised] --> B[AssumeRole<br>to CI]
    B --> C[AssumeRole<br>to Staging]
    C --> D[AssumeRole<br>to Production]
    D --> E[Full access to<br>customer data]
```

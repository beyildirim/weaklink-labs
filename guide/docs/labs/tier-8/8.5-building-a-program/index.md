# Lab 8.5: Building a Supply Chain Security Program

<div class="lab-meta">
  <span>Phase 1 ~10 min | Phase 2 ~20 min | Phase 3 ~20 min | Phase 4 ~10 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../8.1-slsa-deep-dive/">Lab 8.1</a>, <a href="../8.2-ssdf-nist/">Lab 8.2</a>, <a href="../../tier-7/7.3-ir-playbook/">Lab 7.3</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="assess/" class="phase-step upcoming">Assess</a>
  <span class="phase-arrow">›</span>
  <a href="plan/" class="phase-step upcoming">Plan</a>
  <span class="phase-arrow">›</span>
  <a href="document/" class="phase-step upcoming">Document</a>
</div>

You have the technical labs (Tiers 1-6), detection and response (Tier 7), and framework mapping (Tier 8). This capstone brings it all together into a cohesive program for a 500-person organization.

### Attack Flow

```mermaid
graph LR
    A[Governance] --> B[Tooling]
    B --> C[Training]
    C --> D[Monitoring]
    D --> E[Incident<br>Response]
    E --> F[Continuous<br>Improvement]
```

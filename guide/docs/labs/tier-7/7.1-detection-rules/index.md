# Lab 7.1: Building Detection Rules for Supply Chain Attacks

<div class="lab-meta">
  <span>Phase 1 ~10 min | Phase 2 ~15 min | Phase 3 ~15 min | Phase 4 ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-1/1.1-dependency-resolution.md">Lab 1.1</a>, <a href="../../tier-1/1.2-dependency-confusion/">Lab 1.2</a>, <a href="../../tier-1/1.3-typosquatting.md">Lab 1.3</a>, <a href="../../tier-1/1.4-lockfile-injection.md">Lab 1.4</a>, <a href="../../tier-1/1.5-manifest-confusion.md">Lab 1.5</a>, <a href="../../tier-1/1.6-phantom-dependencies.md">Lab 1.6</a></span>
</div>

<div class="phase-stepper">
  <span class="phase-step current">Overview</span>
  <span class="phase-arrow">›</span>
  <a href="understand/" class="phase-step upcoming">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="investigate/" class="phase-step upcoming">Investigate</a>
  <span class="phase-arrow">›</span>
  <a href="validate/" class="phase-step upcoming">Validate</a>
  <span class="phase-arrow">›</span>
  <a href="improve/" class="phase-step upcoming">Improve</a>
</div>

You completed Tier 1. You know how the attacks work. Now put yourself in the SOC analyst's chair: detect them after the fact, from log telemetry, before the attacker finishes exfiltrating.

### Attack Flow

```mermaid
graph LR
    A[Supply chain<br>attack happens] --> B[Logs generated<br>across sources]
    B --> C[Detection rule<br>matches pattern]
    C --> D[Alert fires<br>in SIEM]
    D --> E[Analyst triages<br>and investigates]
```

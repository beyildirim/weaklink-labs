# Lab 7.5: Threat Modeling for Software Supply Chains

<div class="lab-meta">
  <span>Understand: ~10 min | Investigate: ~15 min | Validate: ~15 min | Improve: ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../7.1-detection-rules/">Lab 7.1</a></span>
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

Detection, triage, and tools are reactive. Threat modeling is proactive: systematically identify where your supply chain can be attacked before an attacker does. This lab applies STRIDE to supply chain trust boundaries and produces a prioritized remediation roadmap.

### Attack Flow

```mermaid
graph LR
    A[Map supply<br>chain] --> B[Identify trust<br>boundaries]
    B --> C[Apply STRIDE<br>per boundary]
    C --> D[Rank threats<br>by risk]
    D --> E[Plan<br>mitigations]
```

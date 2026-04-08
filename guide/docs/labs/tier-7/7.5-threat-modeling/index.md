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

!!! tip "Related Labs"
    - **Prerequisite:** [7.1 Building Detection Rules](../7.1-detection-rules/index.md) — Detection rules inform what threats need modeling
    - **See also:** [6.4 Multi-Vector Chained Attack](../../tier-6/6.4-multi-vector-attack/index.md) — Multi-vector attacks show why comprehensive threat modeling matters
    - **See also:** [8.5 Building a Supply Chain Security Program](../../tier-8/8.5-building-a-program/index.md) — Threat modeling is a foundation for a supply chain security program
    - **See also:** [7.3 Incident Response Playbook](../7.3-ir-playbook/index.md) — IR playbooks address the threats identified through modeling

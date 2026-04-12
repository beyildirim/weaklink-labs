# Lab 7.2: Supply Chain Incident Triage

<div class="lab-meta">
  <span>Understand: ~5 min | Investigate: ~15 min | Validate: ~10 min | Improve: ~10 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-1/1.2-dependency-confusion/">Lab 1.2</a></span>
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

It is 14:47 on a Tuesday. Your pager fires:

> **[CRITICAL] Detection Rule 7100001: Internal package `internal-utils@99.0.0` installed in CI pipeline `build-api-service` 3 hours ago. Source: public PyPI.**

You are the on-call SOC analyst. Three hours have passed since the malicious package was installed. Every minute you spend investigating is a minute the attacker has to deepen their access.

### Attack Flow

```mermaid
graph LR
    A[Alert fires] --> B[Scope blast<br>radius]
    B --> C[Identify affected<br>systems]
    C --> D[Classify<br>severity]
    D --> E[Escalate and<br>contain]
```

> **Related Labs**
>
> - **Next:** [7.3 Incident Response Playbook](../7.3-ir-playbook/index.md) — IR playbooks formalize the triage process into response procedures
> - **See also:** [6.7 Case Study: Codecov Bash Uploader](../../tier-6/6.7-case-study-codecov/index.md) — Codecov is a real-world triage scenario for CI supply chain breaches
> - **See also:** [6.10 Case Study: Equifax Breach](../../tier-6/6.10-case-study-equifax/index.md) — Equifax shows consequences of poor incident triage

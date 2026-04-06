# Lab 0.4: How CI/CD Works

<div class="lab-meta">
  <span>~25 min hands-on | ~5 min reference</span>
  <span class="difficulty beginner">Beginner</span>
  <span>Prerequisites: <a href="../../tier-0/0.1-version-control/">Lab 0.1</a></span>
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

Modern software is built, tested, and deployed automatically by CI/CD pipelines. This lab covers how pipelines run, how they access secrets, and why they are a massive target for attackers.

### Attack Flow

```mermaid
graph LR
    A[Developer has repo write access] -->|Modifies CI workflow YAML| B[Adds secret exfiltration step]
    B -->|git push| C[CI pipeline triggers automatically]
    C -->|Runner injects secrets into env| D[Attacker's step reads DEPLOY_KEY]
    D --> E[Secret exfiltrated]
```

## Environment

This lab uses Gitea with **Gitea Actions** (fully compatible with GitHub Actions syntax). When you push code, Gitea checks `.gitea/workflows/` for YAML configs matching the event and spins up a **Runner** to execute the workflow steps.

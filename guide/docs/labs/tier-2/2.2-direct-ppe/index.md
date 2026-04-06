# Lab 2.2: Direct Poisoned Pipeline Execution (PPE)

<div class="lab-meta">
  <span>~20 min hands-on | ~15 min reference</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../2.1-cicd-fundamentals/">Lab 2.1</a></span>
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

CI configs are code. They live in the repo alongside application source. When a developer opens a PR, the CI system runs the pipeline as defined **in the PR branch**, not the target branch. The PR author controls what the pipeline executes. Direct PPE: modify the CI config in a PR, exfiltrate secrets before anyone reviews it.

### Attack Flow

```mermaid
graph LR
    A[Attacker submits PR] --> B[PR modifies CI config]
    B --> C[CI runs attacker's<br>modified pipeline]
    C --> D[Pipeline exfiltrates<br>secrets via curl]
    D --> E[Deploy token stolen<br>before review]
```

## Environment

| Service | Address | Description |
|---------|---------|-------------|
| Gitea | `gitea:3000` | Git server hosting `wl-webapp` with CI secrets |
| Workstation | (your shell) | Development environment |

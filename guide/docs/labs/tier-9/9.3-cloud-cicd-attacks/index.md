# Lab 9.3: Cloud CI/CD Attacks (Beyond GitHub Actions)

<div class="lab-meta">
  <span>Phase 1 ~10 min | Phase 2 ~15 min | Phase 3 ~10 min | Phase 4 ~5 min</span>
  <span class="difficulty advanced">Advanced</span>
  <span>Prerequisites: <a href="../../tier-2/2.1-cicd-fundamentals/">Lab 2.1</a></span>
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

Cloud-native CI/CD services (AWS CodeBuild, GCP Cloud Build, Azure DevOps) have deep IAM integration. A misconfigured build role does not just leak a GitHub token. It can give an attacker access to every resource in your cloud account. Three attack vectors: CodeBuild environment variable injection via SSM, Cloud Build substitution variable abuse, and privilege escalation through overprivileged build roles.

### Attack Flow

```mermaid
graph LR
    A[Build role has<br>admin access] --> B[Attacker modifies<br>buildspec]
    B --> C[CodeBuild runs with<br>elevated privileges]
    C --> D[Production secrets<br>read from SSM]
    D --> E[AWS keys stolen /<br>backdoor created]
```

!!! tip "Related Labs"
    - **Prerequisite:** [2.1 CI/CD Fundamentals](../../tier-2/2.1-cicd-fundamentals/index.md) — CI/CD fundamentals before exploring cloud-native CI/CD attacks
    - **See also:** [2.2 Direct Poisoned Pipeline Execution](../../tier-2/2.2-direct-ppe/index.md) — Pipeline poisoning techniques adapt to cloud CI/CD platforms
    - **See also:** [2.8 Workflow Run & Cross-Workflow Attacks](../../tier-2/2.8-workflow-run-attacks/index.md) — Workflow run attacks have cloud-native equivalents
    - **See also:** [9.4 IAM Chain Abuse](../9.4-iam-chain-abuse/index.md) — IAM chain abuse often starts from compromised CI/CD

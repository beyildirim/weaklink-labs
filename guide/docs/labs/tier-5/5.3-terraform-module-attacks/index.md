# Lab 5.3: Terraform Module and Provider Attacks

<div class="lab-meta">
  <span>Understand: ~10 min | Break: ~10 min | Defend: ~10 min | Detect: ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: <a href="../5.2-helm-poisoning/">Lab 5.2</a></span>
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

`terraform apply` executes third-party code. Modules and providers are downloaded and run with the same permissions as the Terraform process, which typically has full cloud account access. A module that says "create an S3 bucket" can silently exfiltrate `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` via a `local-exec` provisioner. The bucket gets created. The credentials get stolen. Output says "Apply complete!"

### Attack Flow

```mermaid
graph LR
    A[Terraform module from registry] --> B[local-exec provisioner]
    B --> C[terraform apply]
    C --> D[Exfiltrates env vars]
```

## Environment

| Component | Path | Description |
|-----------|------|-------------|
| Infrastructure Code | `/app/infra/` | Terraform project using community modules |
| S3 Bucket Module | `/app/infra/modules/s3-bucket/` | Community module with hidden `local-exec` provisioner |
| Monitoring Module | `/app/infra/modules/monitoring/` | Clean module for CloudWatch alarms |

> **Related Labs**
>
> - **Prerequisite:** [5.2 Helm Chart Poisoning](../5.2-helm-poisoning/index.md) — Helm chart poisoning introduces the IaC trust-boundary mindset before Terraform modules
> - **Next:** [5.4 Ansible Galaxy and Collection Attacks](../5.4-ansible-galaxy/index.md) — Ansible Galaxy attacks apply similar patterns to another IaC tool
> - **See also:** [5.1 How Helm Charts Resolve Dependencies](../5.1-helm-resolution/index.md) — Helm resolution faces the same dependency trust challenges
> - **See also:** [1.2 Dependency Confusion](../../tier-1/1.2-dependency-confusion/index.md) — Module registry confusion mirrors dependency confusion

# Lab 5.3: Terraform Module and Provider Attacks

<div class="lab-meta">
  <span>Understand: ~10 min | Break: ~10 min | Defend: ~10 min | Detect: ~5 min</span>
  <span class="difficulty intermediate">Intermediate</span>
  <span>Prerequisites: None</span>
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

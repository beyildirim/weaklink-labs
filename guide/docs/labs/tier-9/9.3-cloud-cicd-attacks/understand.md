# Lab 9.3: Cloud CI/CD Attacks (Beyond GitHub Actions)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Understand</span>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step upcoming">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

**Goal:** Understand how AWS CodeBuild, GCP Cloud Build, and Azure DevOps differ from GitHub Actions.

## Trust model comparison

| Property | GitHub Actions | AWS CodeBuild | GCP Cloud Build |
|----------|---------------|---------------|-----------------|
| **Secret storage** | GitHub Secrets (per-repo) | SSM Parameter Store (account-wide) | Secret Manager (project-wide) |
| **Build identity** | GITHUB_TOKEN (scoped) | IAM Role (can be overprivileged) | Service Account (project-level) |
| **Secret scoping** | Per-environment, per-repo | By IAM policy on Parameter Store path | By IAM binding on Secret Manager |

**The critical difference:** If the CodeBuild IAM role has `ssm:GetParameter` on `Resource: "*"`, ANY build can read ANY parameter in the account, including production database passwords.

## Vulnerable configurations

```bash
cat buildspec-vulnerable.yml    # Fetches /prod/ secrets
cat cloudbuild-vulnerable.yaml  # User-controlled substitution variables
cat iam-policy-vulnerable.json  # ssm:*, s3:*, iam:PassRole, sts:AssumeRole on *
```

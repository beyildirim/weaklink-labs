# Lab 9.4: IAM Chain Abuse

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

**Goal:** Map the trust chain across four AWS accounts.

## The trust chain

```
Dev Account (111111111111)
  └── dev-deploy can AssumeRole → CI Account ci-runner

CI Account (222222222222)
  └── ci-runner can AssumeRole → Staging Account staging-deploy

Staging Account (333333333333)
  └── staging-deploy can AssumeRole → Production Account prod-deploy

Production Account (444444444444)
  └── prod-deploy has access to customer data, databases, secrets
```

## Trust policy analysis

```bash
cat trust-policies/dev-account-role.json
cat trust-policies/ci-account-role.json
cat trust-policies/staging-account-role.json
cat trust-policies/prod-account-role.json
```

Every trust policy has the same problem:

| Property | Value |
|----------|-------|
| Principal | Account root (not a specific role) |
| Conditions | None |
| ExternalId | Missing |
| Source IP restriction | Missing |
| Session duration cap | Missing |

Each policy says: "I trust anyone in account X to assume this role, at any time, from any IP."

## The "confused deputy" amplification

The CI Account trust policy uses `arn:aws:iam::111111111111:root`, meaning ANY entity in the dev account can assume `ci-runner`. Not just `dev-deploy`, but also any Lambda, any EC2 instance profile, any other role.

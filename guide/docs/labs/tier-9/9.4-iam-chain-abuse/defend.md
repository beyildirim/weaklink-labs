# Lab 9.4: IAM Chain Abuse

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Defend</span>
  <span class="phase-arrow">›</span>
  <a href="../detect/" class="phase-step upcoming">Detect</a>
</div>

**Goal:** Add conditions, implement OIDC, apply zero-trust.

## Fix 1: External ID conditions

```json
{
  "Effect": "Allow",
  "Principal": {"AWS": "arn:aws:iam::222222222222:role/ci-runner"},
  "Action": "sts:AssumeRole",
  "Condition": {
    "StringEquals": {"sts:ExternalId": "ci-to-staging-7f3a9b2c-4e1d-48a7-b6f5"}
  }
}
```

Principal is a specific role ARN (not account root). ExternalId is a shared secret.

## Fix 2: Source IP and time-of-day conditions

```json
{
  "Condition": {
    "IpAddress": {"aws:SourceIp": ["10.200.0.0/16"]},
    "DateGreaterThan": {"aws:CurrentTime": "2026-01-01T06:00:00Z"},
    "DateLessThan": {"aws:CurrentTime": "2026-01-01T22:00:00Z"}
  }
}
```

## Fix 3: OIDC federation (eliminates the chain)

```json
{
  "Principal": {"Federated": "arn:aws:iam::333333333333:oidc-provider/token.actions.githubusercontent.com"},
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringLike": {"token.actions.githubusercontent.com:sub": "repo:myorg/myrepo:ref:refs/heads/main"}
  }
}
```

No long-lived credentials, scoped to repository and branch, short-lived JWT tokens, no transitive chain.

## Fix 4: Hardened trust policy template

For each hop: specific role ARN principal, ExternalId, source IP, session duration cap (1 hour), session tags.

## Final verification

```bash
weaklink verify 9.4
```

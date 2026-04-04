# Hint 1: Understanding IAM Trust Chains

A trust chain forms when Account A trusts Account B, which trusts Account C, which trusts Account D. Each individual trust relationship may look reasonable in isolation, but the transitive chain creates an attack path from A to D.

## The Four-Account Chain

```
Dev Account (111111111111)
  └── Role: dev-deploy
      └── Trusts: developers (humans)
      └── Can AssumeRole → CI Account

CI Account (222222222222)
  └── Role: ci-runner
      └── Trusts: Dev Account (AssumeRole)
      └── Can AssumeRole → Staging Account

Staging Account (333333333333)
  └── Role: staging-deploy
      └── Trusts: CI Account (AssumeRole)
      └── Can AssumeRole → Production Account

Production Account (444444444444)
  └── Role: prod-deploy
      └── Trusts: Staging Account (AssumeRole)
      └── Has access to production S3, RDS, DynamoDB
```

## The Attack Path

1. **Initial access:** Attacker compromises a dev dependency (malicious npm package in a dev tool). The malicious package runs in the developer's environment and steals the `dev-deploy` role credentials from `~/.aws/credentials` or environment variables.

2. **Hop 1: Dev -> CI:** Attacker uses `dev-deploy` credentials to `AssumeRole` into the CI account's `ci-runner` role. This is a normal operation -- developers trigger CI builds constantly.

3. **Hop 2: CI -> Staging:** The `ci-runner` role can assume `staging-deploy` because CI deploys to staging. Attacker uses these credentials to hop to the staging account.

4. **Hop 3: Staging -> Production:** The `staging-deploy` role can assume `prod-deploy` for blue-green deployments. Attacker now has production access.

## What to Look For

Examine the trust policies in `src/trust-policies/`. Each role's `AssumeRolePolicyDocument` defines who can assume it. The vulnerability is that none of them have **conditions** (no external ID, no source IP restriction, no MFA requirement).

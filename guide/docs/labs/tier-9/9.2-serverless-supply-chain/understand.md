# Lab 9.2: Serverless Supply Chain

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

**Goal:** Map the attack surface: code, dependencies, layers, runtime, IAM.

## Lambda Layers

Layers are ZIP archives extracted to `/opt/` BEFORE your function code. `/opt/python/sitecustomize.py` auto-loads on Python interpreter startup.

| Property | Implication |
|----------|-------------|
| Layers load before handler code | Attacker code runs first |
| `/opt/python/sitecustomize.py` auto-loads | No opt-in required |
| Layers referenced by ARN | Without version pin, latest version is used |
| Layer contents not inspected at deploy time | No scanning, no signature verification |

## Deployment pipeline

```bash
cat template.yaml
```

| Property | Vulnerable | Hardened |
|----------|-----------|---------|
| Layer reference | By name (no version pin) | By ARN with version number |
| IAM permissions | `dynamodb:*`, `s3:*`, `sns:*` | Specific actions on specific resources |
| Network access | Default (internet) | VPC-isolated (private subnet) |
| Secrets | Hardcoded in env vars | Parameter Store at runtime |

## Dependency configuration

`requirements.txt` references internal packages (`wl-order-utils`, `wl-notification-client`) but `sam build` runs `pip install` with default index. Public PyPI queried first.

# Lab 9.3: Cloud CI/CD Attacks (Beyond GitHub Actions)

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

**Goal:** Least-privilege IAM, input validation, encrypted parameters, build isolation.

## Fix 1: Scope SSM Parameter access

| Permission | Vulnerable | Hardened |
|-----------|-----------|---------|
| SSM GetParameter | `Resource: "*"` | `Resource: "arn:...parameter/build/*"` with tag condition |
| S3 | `s3:*` on `*` | `s3:GetObject, s3:PutObject` on specific bucket |
| IAM/STS | `iam:PassRole, sts:AssumeRole` on `*` | **Explicit Deny** on `iam:*, sts:AssumeRole` |

Build-time secrets: `/build/*`. Production secrets: `/prod/*`. Build role only accesses `/build/*`.

## Fix 2: Validate substitution variables

```yaml
- name: 'gcr.io/cloud-builders/docker'
  entrypoint: 'bash'
  args:
    - '-euo'
    - 'pipefail'
    - '-c'
    - |
      if [[ ! "${_IMAGE_NAME}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "ERROR: Invalid _IMAGE_NAME"; exit 1
      fi
```

Hardcode test commands. Use `MUST_MATCH` substitution option. Use a dedicated build service account.

## Fix 3: Harden the buildspec

Key changes: only build-scoped parameters, `--secret` mount instead of `--build-arg`, `npm ci --ignore-scripts`, input validation on commit hash.

## Fix 4: Build config change detection

Flag changes to `buildspec.yml`, `cloudbuild.yaml`, `azure-pipelines.yml` for mandatory security review.

## Final verification

```bash
weaklink verify 9.3
```

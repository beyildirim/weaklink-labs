# Lab 9.3: Cloud CI/CD Attacks (Beyond GitHub Actions)

<div class="phase-stepper">
  <a href="../" class="phase-step done">Overview</a>
  <span class="phase-arrow">›</span>
  <a href="../understand/" class="phase-step done">Understand</a>
  <span class="phase-arrow">›</span>
  <a href="../break/" class="phase-step done">Break</a>
  <span class="phase-arrow">›</span>
  <a href="../defend/" class="phase-step done">Defend</a>
  <span class="phase-arrow">›</span>
  <span class="phase-step current">Detect</span>
</div>

<div class="no-terminal-notice">Reference material. No terminal needed.</div>

**Goal:** Detect secret access, privilege escalation, and build config tampering.

CloudTrail indicators:

| Event | Severity |
|-------|----------|
| `GetParameter` with path `/prod/*` from CodeBuild | Critical |
| `AssumeRole` from CodeBuild to non-build role | Critical |
| `CreateUser` or `CreateAccessKey` from CodeBuild | Critical |
| `PutParameter` from CodeBuild | High |
| Build duration > 3x normal | Medium |

## MITRE ATT&CK Mapping

| Technique | ID | Relevance |
|-----------|-----|-----------|
| Supply Chain Compromise: Software Supply Chain | [T1195.002](https://attack.mitre.org/techniques/T1195/002/) | Build config modified to inject malicious steps |
| Unsecured Credentials: Credentials In Files | [T1552.001](https://attack.mitre.org/techniques/T1552/001/) | SSM parameters accessed by overprivileged build role |
| Valid Accounts: Cloud Accounts | [T1078](https://attack.mitre.org/techniques/T1078/) | Build role escalated to admin via AssumeRole |

### CI Integration

Add this workflow to detect overprivileged build roles and unauthorized secret access patterns in cloud CI configs. Save as `.github/workflows/cloud-cicd-audit.yml`:

```yaml
name: Cloud CI/CD Security Audit

on:
  pull_request:
    paths:
      - "buildspec.yml"
      - "buildspec.yaml"
      - "cloudbuild.yaml"
      - "cloudbuild.yml"
      - "**/buildspec*"
      - "iam/**"
      - "terraform/**iam*"

permissions:
  contents: read

jobs:
  audit-cloud-cicd:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Check buildspec for privilege escalation patterns
        run: |
          EXIT_CODE=0
          for f in $(find . -name 'buildspec*' -o -name 'cloudbuild*' 2>/dev/null); do
            # Check for IAM/STS actions in build steps
            IAM_CALLS=$(grep -nE '(aws iam|aws sts assume-role|gcloud iam|CreateAccessKey|AssumeRole)' "$f" || true)
            if [ -n "$IAM_CALLS" ]; then
              echo "::error file=$f::IAM/STS operations found in build config:"
              echo "$IAM_CALLS"
              echo ""
              echo "Build steps should not create IAM users or assume non-build roles."
              EXIT_CODE=1
            fi

            # Check for secret access outside expected paths
            SECRET_ACCESS=$(grep -nE '(ssm get-parameter.*--name.*/prod|secretsmanager get-secret)' "$f" || true)
            if [ -n "$SECRET_ACCESS" ]; then
              echo "::error file=$f::Production secret access from build config:"
              echo "$SECRET_ACCESS"
              echo ""
              echo "Build roles should only access build-scoped secrets."
              EXIT_CODE=1
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: No privilege escalation patterns in build configs."
          fi
          exit $EXIT_CODE

      - name: Verify build role policies use explicit deny
        run: |
          for f in $(find . -name '*.tf' -name '*iam*' 2>/dev/null; \
            find iam/ -name '*.json' 2>/dev/null); do
            if grep -q 'codebuild\|CodeBuild' "$f"; then
              DENY_CHECK=$(grep -c '"Effect".*"Deny"\|effect.*=.*"Deny"' "$f" || true)
              if [ "$DENY_CHECK" -eq 0 ]; then
                echo "::warning file=$f::CodeBuild IAM policy has no explicit Deny statements."
                echo "Add Deny on iam:*, sts:AssumeRole for non-build roles."
              fi
            fi
          done
          echo "IAM policy check complete."
```

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- Cloud CI/CD services have deeper IAM integration than GitHub Actions. A misconfigured build role can access any secret and any IAM role in the account.
- Build config files are attack vectors. Modifying `buildspec.yml` is equivalent to modifying the CI pipeline and often bypasses code review.
- Explicit Deny on IAM/STS prevents escalation even if Allow statements are overly broad.

## Further Reading

- [AWS: CodeBuild Security Best Practices](https://docs.aws.amazon.com/codebuild/latest/userguide/security.html)
- [GCP: Cloud Build Security](https://cloud.google.com/build/docs/securing-builds)
- [MITRE ATT&CK: Unsecured Credentials (T1552)](https://attack.mitre.org/techniques/T1552/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

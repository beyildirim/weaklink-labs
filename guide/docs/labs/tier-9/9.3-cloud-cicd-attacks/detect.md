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

## What You Learned

- Cloud CI/CD services have deeper IAM integration than GitHub Actions. A misconfigured build role can access any secret and any IAM role in the account.
- Build config files are attack vectors. Modifying `buildspec.yml` is equivalent to modifying the CI pipeline and often bypasses code review.
- Explicit Deny on IAM/STS prevents escalation even if Allow statements are overly broad.

## Further Reading

- [AWS: CodeBuild Security Best Practices](https://docs.aws.amazon.com/codebuild/latest/userguide/security.html)
- [GCP: Cloud Build Security](https://cloud.google.com/build/docs/securing-builds)
- [MITRE ATT&CK: Unsecured Credentials (T1552)](https://attack.mitre.org/techniques/T1552/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

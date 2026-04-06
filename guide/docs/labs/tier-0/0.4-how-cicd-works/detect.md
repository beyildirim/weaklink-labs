# Lab 0.4: How CI/CD Works

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

## Catching Pipeline Modifications

What to look for:

- Commits modifying `.gitea/workflows/`, `.github/workflows/`, `Jenkinsfile`, or other CI configs
- Pipeline steps that access secrets not required by the build
- Outbound network connections from CI runners during build
- New or modified pipeline steps added outside normal PR review

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | CI config changes, workflow file modifications |
| Unix Shell | T1059.004 | Unexpected shell commands in pipeline steps |
| Credentials in Files | T1552.001 | Secrets written to disk, echoed to logs |

---

## What You Learned

- **CI/CD pipelines execute whatever is in the workflow file.** Anyone with push access to the repository can modify the pipeline behavior.
- **Secrets are injected into the runner environment.** A malicious pipeline step can read and exfiltrate them.
- **Branch protection and ephemeral credentials** are the primary defenses against Poisoned Pipeline Execution.

## Further Reading

- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
- [Cider Security: Top 10 CI/CD Risks](https://www.cidersecurity.io/top-10-cicd-security-risks/)
- [MITRE ATT&CK: T1195.002 Compromise Software Supply Chain](https://attack.mitre.org/techniques/T1195/002/)

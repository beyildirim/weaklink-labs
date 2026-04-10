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
- Pipeline steps that access secrets not required by the job
- Outbound network connections from CI runners during build
- New or modified pipeline steps added outside normal PR review

### MITRE ATT&CK Mapping

| Technique | ID | What to Monitor |
|-----------|----|-----------------|
| Compromise Software Supply Chain | T1195.002 | CI config changes, workflow file modifications |
| Unix Shell | T1059.004 | Unexpected shell commands in pipeline steps |
| Credentials in Files | T1552.001 | Secrets written to disk, echoed to logs |

---

## How to Think About Detection

At this stage, the important habit is treating pipeline changes as high-risk code changes, not routine config edits.

Ask:

- Did someone change a workflow file, runner config, or secret usage?
- Does the pipeline now make outbound requests or print environment data?
- Would a normal reviewer immediately understand why the change is needed?

If the answer is no, stop treating the pipeline as trusted until the change is explained and reviewed.

If you want concrete rule examples or CI enforcement snippets later, use the shared resources linked at the bottom of the page.

---

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

---

## What You Learned

- **CI/CD pipelines execute whatever is in the workflow file.** Anyone with push access to the repository can modify the pipeline behavior.
- **Secrets are injected into the runner environment.** A malicious pipeline step can read and exfiltrate them.
- **Branch protection and ephemeral credentials** are the primary defenses against Poisoned Pipeline Execution.

## Further Reading

- [OWASP Top 10 CI/CD Security Risks](https://owasp.org/www-project-top-10-ci-cd-security-risks/)
- [Cider Security: Top 10 CI/CD Risks](https://www.cidersecurity.io/top-10-cicd-security-risks/)
- [MITRE ATT&CK: T1195.002 Compromise Software Supply Chain](https://attack.mitre.org/techniques/T1195/002/)

See also: [Detection Rule Library](../../../resources/detection-rules.md) | [CI Security Snippets](../../../resources/ci-snippets.md)

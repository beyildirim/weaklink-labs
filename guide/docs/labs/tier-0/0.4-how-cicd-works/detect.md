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

### CI Integration

Add this workflow to flag changes to CI configuration files and detect secret access in pipeline steps. Save as `.github/workflows/pipeline-audit.yml`:

```yaml
name: Pipeline Modification Audit

on:
  pull_request:
    paths:
      - ".github/workflows/**"
      - ".gitea/workflows/**"
      - "Jenkinsfile"
      - ".gitlab-ci.yml"

permissions:
  contents: read

jobs:
  audit-pipeline-changes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Flag CI config modifications
        run: |
          echo "--- Scanning CI config changes in this PR ---"
          CHANGED=$(git diff --name-only origin/main...HEAD -- \
            '.github/workflows/' '.gitea/workflows/' \
            '.gitlab-ci.yml' 'Jenkinsfile' \
            '.circleci/' '.travis.yml')
          if [ -z "$CHANGED" ]; then
            echo "PASS: No CI config files modified."
            exit 0
          fi
          echo "::warning::CI pipeline configs modified in this PR:"
          echo "$CHANGED"

      - name: Check for secret exfiltration patterns
        run: |
          EXIT_CODE=0
          for f in $(git diff --name-only origin/main...HEAD -- \
            '.github/workflows/' '.gitea/workflows/'); do
            if [ -f "$f" ]; then
              if grep -nE '(curl|wget|nc |ncat |base64|printenv|\$\{secrets\.)' "$f"; then
                echo "::error file=$f::Potential secret exfiltration pattern detected."
                EXIT_CODE=1
              fi
            fi
          done
          if [ "$EXIT_CODE" -eq 0 ]; then
            echo "PASS: No suspicious patterns found in workflow changes."
          fi
          exit $EXIT_CODE
```

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
